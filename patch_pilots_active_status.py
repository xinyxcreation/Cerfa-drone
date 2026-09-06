#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime
import shutil
import re
import subprocess
import sys

ROOT = Path.cwd()
BACKEND = ROOT / "backend"
FRONTEND = ROOT / "frontend"

if not BACKEND.exists() or not FRONTEND.exists():
    print("❌ Lance ce script depuis ~/GitHub/Cerfa-drone")
    sys.exit(1)

STAMP = datetime.now().strftime("%Y%m%d-%H%M%S")

FILES = {
    "migration": BACKEND / "src/database/migrations/033_add_pilot_active_status.sql",
    "repository": BACKEND / "src/repositories/CompanyUserRepository.ts",
    "service": BACKEND / "src/services/CompanyPilotService.ts",
    "controller": BACKEND / "src/controllers/CompanyPilotController.ts",
    "model": FRONTEND / "lib/features/management/models/company_pilot.dart",
    "pilots_service": FRONTEND / "lib/features/management/services/pilots_service.dart",
    "management": FRONTEND / "lib/features/management/presentation/management_page.dart",
}

backups = []


def fail(message):
    print()
    print("❌", message)
    print("↩️ Restauration automatique...")
    for original, backup in reversed(backups):
        if backup.exists():
            shutil.copy2(backup, original)
            print(f"   ↩️ {original}")
    sys.exit(1)


def backup(path):
    if not path.exists():
        fail(f"Fichier introuvable : {path}")

    backup_path = path.with_name(
        path.name + f".bak-pilot-active-{STAMP}"
    )

    shutil.copy2(path, backup_path)
    backups.append((path, backup_path))
    print(f"💾 Backup : {backup_path}")


def read(path):
    return path.read_text(encoding="utf-8")


def write(path, content):
    path.write_text(content, encoding="utf-8")


def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        fail(
            f"{label}: occurrence attendue = 1, trouvée = {count}"
        )
    return text.replace(old, new)


print("=" * 70)
print("🚀 PILOTES — STATUT ACTIF / INACTIF")
print("=" * 70)

# ------------------------------------------------------------------
# BACKUPS
# ------------------------------------------------------------------

for key, path in FILES.items():
    if key != "migration":
        backup(path)

# ------------------------------------------------------------------
# 1 — MIGRATION
# ------------------------------------------------------------------

migration = """ALTER TABLE company_users
    ADD COLUMN is_pilot_active BOOLEAN NOT NULL DEFAULT FALSE
    AFTER is_pilot;

UPDATE company_users
SET is_pilot_active = is_pilot
WHERE is_pilot = TRUE;
"""

if FILES["migration"].exists():
    fail(
        f"La migration existe déjà : {FILES['migration']}\n"
        "Supprime-la uniquement si tu sais qu'elle n'a jamais été exécutée."
    )

write(FILES["migration"], migration)

print("✅ Migration 033 créée")

# ------------------------------------------------------------------
# 2 — REPOSITORY BACKEND
# ------------------------------------------------------------------

path = FILES["repository"]
text = read(path)

text = replace_once(
    text,
    """    is_pilot: boolean;
    is_active: boolean;
""",
    """    is_pilot: boolean;
    is_pilot_active: boolean;
    is_active: boolean;
""",
    "CompanyUser interface",
)

text = replace_once(
    text,
    """    is_pilot: boolean;
    company_name: string;
""",
    """    is_pilot: boolean;
    is_pilot_active: boolean;
    company_name: string;
""",
    "CompanyMember interface",
)

# Remplace complètement findPilotsByCompanyId
start = text.find("    public async findPilotsByCompanyId(")
if start == -1:
    fail("findPilotsByCompanyId introuvable")

end = text.find(
    "    public async create(",
    start,
)
if end == -1:
    fail("fin de findPilotsByCompanyId introuvable")

new_method = """    public async findPilotsByCompanyId(
        companyId: string
    ): Promise<CompanyMember[]> {

        const [rows] =
            await this.db.query<CompanyMember[]>(
                `
                SELECT
                    cu.id,
                    cu.company_id,
                    c.name AS company_name,
                    cu.user_id,

                    u.email,
                    u.firstname,
                    u.lastname,
                    u.phone,

                    cu.joined_at,

                    r.code AS role_code,
                    r.label AS role_label,

                    cu.is_pilot,
                    cu.is_pilot_active

                FROM company_users cu

                INNER JOIN users u
                    ON u.id = cu.user_id

                INNER JOIN companies c
                    ON c.id = cu.company_id

                INNER JOIN roles r
                    ON r.id = cu.role_id

                WHERE cu.company_id = ?

                AND cu.is_pilot = TRUE

                AND cu.is_active = TRUE
                AND cu.deleted_at IS NULL

                AND u.is_active = TRUE
                AND u.deleted_at IS NULL

                AND r.is_active = TRUE
                AND r.deleted_at IS NULL

                ORDER BY
                    u.lastname,
                    u.firstname,
                    u.email
                `,
                [companyId]
            );

        return rows;
    }

"""

text = text[:start] + new_method + text[end:]

# count uniquement les pilotes ACTIFS
text = replace_once(
    text,
    """            AND is_pilot = TRUE
            AND is_active = TRUE
            AND deleted_at IS NULL
""",
    """            AND is_pilot = TRUE
            AND is_pilot_active = TRUE
            AND is_active = TRUE
            AND deleted_at IS NULL
""",
    "countPilotsByCompanyId",
)

# setPilot : synchroniser le nouveau statut
old = """            {
                is_pilot: isPilot
            }
"""
new = """            {
                is_pilot: isPilot,
                is_pilot_active: isPilot
            }
"""
text = replace_once(
    text,
    old,
    new,
    "setPilot",
)

# deactivatePilot devient désactivation du statut uniquement
old = """            {
                is_pilot: false
            }
"""
new = """            {
                is_pilot_active: false
            }
"""
text = replace_once(
    text,
    old,
    new,
    "deactivatePilot",
)

# Ajouter réactivation
marker = """    public async deactivate(
        id: string
    ): Promise<void> {
"""

if marker not in text:
    fail("méthode deactivate(id) introuvable")

reactivate = """    public async reactivatePilot(
        companyId: string,
        userId: string
    ): Promise<void> {

        const membership =
        await this.findByCompanyAndUser(
            companyId,
            userId
        );

        if (!membership) {
            throw new Error(
                'Utilisateur non associé à cette entreprise.'
            );
        }

        await this.baseUpdate(
            this.table,
            membership.id,
            {
                is_pilot: true,
                is_pilot_active: true
            }
        );
    }

"""

text = text.replace(marker, reactivate + marker, 1)

write(path, text)
print("✅ CompanyUserRepository corrigé")

# ------------------------------------------------------------------
# 3 — SERVICE BACKEND
# ------------------------------------------------------------------

path = FILES["service"]
text = read(path)

# Création nouveau compte
text = replace_once(
    text,
    """                is_pilot: true
            );

        return {
""",
    """                is_pilot: true,
                is_pilot_active: true
            );

        return {
""",
    "création pilote nouveau compte",
)

# setCurrentUserPilot doit réactiver/désactiver
old = """        await this.companyUsers.setPilot(
            companyId,
            userId,
            isPilot
        );
"""
new = """        await this.companyUsers.setPilot(
            companyId,
            userId,
            isPilot
        );
"""
# volontairement inchangé : setPilot synchronise déjà les deux champs

# remplacer deactivate par une version qui distingue active/inactive
old = """        if (!membership.is_pilot) {
            throw new NotFoundError(
                'Cet utilisateur n’est pas pilote dans cette entreprise.'
            );
        }

        await this.companyUsers.deactivatePilot(
            companyId,
            pilotId
        );
"""
new = """        if (!membership.is_pilot) {
            throw new NotFoundError(
                'Cet utilisateur n’est pas pilote dans cette entreprise.'
            );
        }

        if (!membership.is_pilot_active) {
            throw new NotFoundError(
                'Ce pilote est déjà désactivé.'
            );
        }

        await this.companyUsers.deactivatePilot(
            companyId,
            pilotId
        );
"""
text = replace_once(
    text,
    old,
    new,
    "désactivation service",
)

# ajouter reactivate juste avant fermeture de classe
class_end = text.rfind("\n}")
if class_end == -1:
    fail("fin CompanyPilotService introuvable")

reactivate_service = """

    // ============================================================
    // RÉACTIVER UN PILOTE
    // ============================================================

    public async reactivate(
        companyId: string,
        requesterRole: string,
        pilotId: string
    ): Promise<void> {

        if (
            requesterRole !== 'OWNER' &&
            requesterRole !== 'MANAGER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de réactiver un pilote.'
            );
        }

        const company =
        await this.companies.findById(
            companyId
        );

        if (!company) {
            throw new NotFoundError(
                'Entreprise introuvable.'
            );
        }

        if (!company.is_active) {
            throw new AuthorizationError(
                'Entreprise désactivée.'
            );
        }

        const membership =
        await this.companyUsers.findByCompanyAndUser(
            companyId,
            pilotId
        );

        if (!membership) {
            throw new NotFoundError(
                'Utilisateur introuvable dans cette entreprise.'
            );
        }

        if (!membership.is_pilot) {
            throw new NotFoundError(
                'Cet utilisateur n’est pas pilote dans cette entreprise.'
            );
        }

        if (membership.is_pilot_active) {
            throw new NotFoundError(
                'Ce pilote est déjà actif.'
            );
        }

        await this.companyUsers.reactivatePilot(
            companyId,
            pilotId
        );
    }
"""

text = text[:class_end] + reactivate_service + text[class_end:]

write(path, text)
print("✅ CompanyPilotService corrigé")

# ------------------------------------------------------------------
# 4 — CONTROLLER BACKEND
# ------------------------------------------------------------------

path = FILES["controller"]
text = read(path)

# liste : retourner les deux statuts
text = replace_once(
    text,
    """                    is_pilot:
                    pilot.is_pilot,

                    certifications:
""",
    """                    is_pilot:
                    pilot.is_pilot,

                    is_pilot_active:
                    pilot.is_pilot_active,

                    certifications:
""",
    "retour statut pilote",
)

# ajouter endpoint reactivate avant fin de classe
class_end = text.rfind("\n}")
if class_end == -1:
    fail("fin CompanyPilotController introuvable")

reactivate_controller = """

    // ============================================================
    // RÉACTIVER UN PILOTE
    // ============================================================

    public async reactivate(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
        await request.jwtVerify<AuthPayload>();

        if (!payload.company_id) {
            throw new AuthorizationError(
                'Entreprise introuvable dans la session.'
            );
        }

        this.checkManagementAccess(
            payload.role
        );

        const params =
        request.params as {
            pilotId: string;
        };

        await this.service.reactivate(
            payload.company_id,
            payload.role,
            params.pilotId
        );

        reply.send({
            success: true
        });
    }
"""

text = text[:class_end] + reactivate_controller + text[class_end:]

write(path, text)
print("✅ CompanyPilotController corrigé")

# ------------------------------------------------------------------
# 5 — FRONTEND MODEL
# ------------------------------------------------------------------

path = FILES["model"]
text = read(path)

text = replace_once(
    text,
    """    required this.joinedAt,
    required this.role,
    required this.certifications,
""",
    """    required this.joinedAt,
    required this.role,
    required this.isActive,
    required this.certifications,
""",
    "CompanyPilot constructor",
)

text = replace_once(
    text,
    """  final DateTime? joinedAt;
  final String role;
  final List<PilotCertification> certifications;
""",
    """  final DateTime? joinedAt;
  final String role;
  final bool isActive;
  final List<PilotCertification> certifications;
""",
    "CompanyPilot fields",
)

text = replace_once(
    text,
    """      role:
          json['role']?.toString().toUpperCase() ?? 'PILOT',
      certifications:
""",
    """      role:
          json['role']?.toString().toUpperCase() ?? 'PILOT',
      isActive:
          json['is_pilot_active'] == true ||
          json['is_pilot_active'] == 1 ||
          json['is_pilot_active']?.toString().toLowerCase() == 'true' ||
          json['is_pilot_active']?.toString() == '1',
      certifications:
""",
    "CompanyPilot JSON",
)

write(path, text)
print("✅ CompanyPilot corrigé")

# ------------------------------------------------------------------
# 6 — FRONTEND SERVICE
# ------------------------------------------------------------------

path = FILES["pilots_service"]
text = read(path)

marker = """  static String _messageFromError(
"""

if marker not in text:
    fail("fin PilotsService introuvable")

reactivate_flutter = """  static Future<void> reactivatePilot(
    String pilotId,
  ) async {
    try {
      await ApiClient.instance.put(
        '/auth/company/pilots/$pilotId/activate',
        data: {},
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de réactiver le pilote.',
        ),
      );
    }
  }

"""

text = text.replace(marker, reactivate_flutter + marker, 1)

write(path, text)
print("✅ PilotsService corrigé")

# ------------------------------------------------------------------
# 7 — ROUTE BACKEND
# ------------------------------------------------------------------

routes_candidates = list(
    (BACKEND / "src").rglob("*.ts")
)

route_file = None

for candidate in routes_candidates:
    try:
        candidate_text = candidate.read_text(encoding="utf-8")
    except Exception:
        continue

    if (
        "/auth/company/pilots/:pilotId" in candidate_text
        and "CompanyPilotController" in candidate_text
    ):
        route_file = candidate
        break

if route_file is None:
    fail(
        "Impossible de trouver automatiquement le fichier de routes "
        "des pilotes."
    )

backup(route_file)

text = read(route_file)

if "/auth/company/pilots/:pilotId/activate" not in text:

    # Chercher la route DELETE existante
    pattern = re.compile(
        r"(?P<indent>^[ \t]*)"
        r"(?P<route>.*?)(?:delete|DELETE)"
        r".*?['\"]?/auth/company/pilots/:pilotId['\"]?.*?\n",
        re.MULTILINE | re.DOTALL,
    )

    # On préfère chercher directement le chemin.
    pos = text.find("/auth/company/pilots/:pilotId")

    if pos == -1:
        fail("Route /auth/company/pilots/:pilotId introuvable")

    # Trouver le début de la ligne
    line_start = text.rfind("\n", 0, pos) + 1

    # Chercher le bloc de route suivant via lignes
    lines = text.splitlines(True)

    target_index = None
    for i, line in enumerate(lines):
        if "/auth/company/pilots/:pilotId" in line:
            target_index = i
            break

    if target_index is None:
        fail("Ligne de route pilote introuvable")

    # Insérer juste avant la route DELETE existante si possible.
    insert_at = target_index

    route_indent = re.match(
        r"^(\s*)",
        lines[target_index]
    ).group(1)

    activation_route = (
        f"{route_indent}app.put(\n"
        f"{route_indent}    '/auth/company/pilots/:pilotId/activate',\n"
        f"{route_indent}    {{\n"
        f"{route_indent}        handler: controller.reactivate.bind(controller)\n"
        f"{route_indent}    }}\n"
        f"{route_indent});\n\n"
    )

    lines.insert(insert_at, activation_route)
    text = "".join(lines)

write(route_file, text)
print(f"✅ Route réactivation ajoutée : {route_file}")

# ------------------------------------------------------------------
# 8 — FRONTEND MANAGEMENT PAGE
# ------------------------------------------------------------------

path = FILES["management"]
text = read(path)

# On cible uniquement la zone PilotsPage -> Detail pilote.
pilot_start = text.find("class PilotsPage")
if pilot_start == -1:
    fail("PilotsPage introuvable")

pilot_end = text.find(
    "// ==================================================================",
    pilot_start + 20,
)

if pilot_end == -1:
    pilot_end = len(text)

pilot_block = text[pilot_start:pilot_end]

# Remplacer l'affichage de la carte de pilote en injectant
# un statut avant les actions, sans dépendre d'un formatage exact.
if "pilot.isActive" not in pilot_block:
    # Chercher le premier Text contenant displayName.
    pattern = re.compile(
        r"(Text\(\s*pilot\.displayName,.*?\n\s*\),)",
        re.DOTALL,
    )

    match = pattern.search(pilot_block)

    if match:
        original = match.group(1)

        replacement = original + """

                    const statusColor = pilot.isActive
                        ? const Color(0xFF16A34A)
                        : Colors.grey;

                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pilot.isActive ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
"""

        pilot_block = (
            pilot_block[:match.start()]
            + replacement
            + pilot_block[match.end():]
        )

# ------------------------------------------------------------------
# Gestion du bouton désactiver/réactiver
# ------------------------------------------------------------------

# Dans toute la zone pilote, remplacer l'appel existant.
pilot_block = pilot_block.replace(
    """await PilotsService.deactivatePilot(pilot.id);""",
    """await PilotsService.deactivatePilot(pilot.id);""",
)

# Ajouter une méthode helper si aucune réactivation n'existe.
if "PilotsService.reactivatePilot" not in pilot_block:

    # Chercher deactivatePilot dans la zone
    pos = pilot_block.find("PilotsService.deactivatePilot")
    if pos == -1:
        # Ce cas signifie que l'action est probablement dans le détail.
        # On poursuit avec la modification du détail plus bas.
        pass

# Remplacer les textes/boutons dans le bloc pilote de façon ciblée.
# On cherche les occurrences de "Désactiver" et adapte uniquement
# celles contenant une action pilote.
pilot_block = re.sub(
    r"""onPressed:\s*pilot\.isActive\s*\?\s*\(\)\s*\{.*?PilotsService\.deactivatePilot\(pilot\.id\);.*?\}""",
    lambda m: m.group(0),
    pilot_block,
    flags=re.DOTALL,
)

# Si l'action de détail est hors de pilot_block, elle sera traitée
# dans la deuxième passe ci-dessous.

text = text[:pilot_start] + pilot_block + text[pilot_end:]

# ------------------------------------------------------------------
# Recherche globale du bloc PilotDetailsPage
# ------------------------------------------------------------------

detail_start = text.find("class PilotDetailsPage")
if detail_start == -1:
    fail("PilotDetailsPage introuvable")

detail_end = text.find(
    "// ==================================================================",
    detail_start + 20,
)

if detail_end == -1:
    detail_end = len(text)

detail = text[detail_start:detail_end]

# Ajouter une méthode de changement de statut avant build.
if "Future<void> _togglePilotStatus()" not in detail:

    build_pos = detail.find("  @override\n  Widget build")

    if build_pos == -1:
        fail("build de PilotDetailsPage introuvable")

    method = """  Future<void> _togglePilotStatus() async {
    try {
      if (widget.pilot.isActive) {
        await PilotsService.deactivatePilot(widget.pilot.id);
      } else {
        await PilotsService.reactivatePilot(widget.pilot.id);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.pilot.isActive
                ? 'Pilote désactivé.'
                : 'Pilote réactivé.',
          ),
        ),
      );

      ManagementBackScope.maybeOf(context)?.onBack();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

"""

    detail = detail[:build_pos] + method + detail[build_pos:]

# Remplacer un bouton d'action existant de désactivation si présent.
detail = detail.replace(
    "const Text('Désactiver le pilote')",
    "Text(widget.pilot.isActive ? 'Désactiver le pilote' : 'Réactiver le pilote')",
)

detail = detail.replace(
    "const Text('Désactiver')",
    "Text(widget.pilot.isActive ? 'Désactiver' : 'Réactiver')",
)

# Si aucun appel toggle n'est présent, remplacer les appels directs.
detail = detail.replace(
    """PilotsService.deactivatePilot(widget.pilot.id)""",
    """_togglePilotStatus()""",
)

text = text[:detail_start] + detail + text[detail_end:]

write(FILES["management"], text)
print("✅ ManagementPage corrigée")

# ------------------------------------------------------------------
# FORMAT
# ------------------------------------------------------------------

print()
print("=" * 70)
print("🎨 FORMATAGE FLUTTER")
print("=" * 70)

result = subprocess.run(
    [
        "dart",
        "format",
        "lib/features/management/models/company_pilot.dart",
        "lib/features/management/services/pilots_service.dart",
        "lib/features/management/presentation/management_page.dart",
    ],
    cwd=FRONTEND,
)

if result.returncode != 0:
    fail("dart format a échoué")

# ------------------------------------------------------------------
# ANALYZE
# ------------------------------------------------------------------

print()
print("=" * 70)
print("🔍 FLUTTER ANALYZE")
print("=" * 70)

result = subprocess.run(
    ["flutter", "analyze"],
    cwd=FRONTEND,
)

if result.returncode != 0:
    fail("flutter analyze a échoué")

# ------------------------------------------------------------------
# BACKEND BUILD
# ------------------------------------------------------------------

print()
print("=" * 70)
print("🔍 TYPESCRIPT BUILD")
print("=" * 70)

result = subprocess.run(
    ["npm", "run", "build"],
    cwd=BACKEND,
)

if result.returncode != 0:
    fail("npm run build a échoué")

print()
print("=" * 70)
print("✅ CORRECTION TERMINÉE")
print("=" * 70)

print()
print("Pilotes :")
print("  🟢 Actif")
print("  ⚪ Inactif")
print("  🔄 Réactiver")
print()
print("Le pilote reste visible après désactivation.")
print("La réactivation remet son statut actif.")
print()
print("⚠️ IMPORTANT : la migration SQL 033 doit être exécutée")
print("avant de redémarrer le backend.")
print()
print("Backups créés :")
for original, backup_path in backups:
    print(f"  {backup_path}")

print()
