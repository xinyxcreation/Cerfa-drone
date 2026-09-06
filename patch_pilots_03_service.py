from pathlib import Path
from datetime import datetime
import shutil

ROOT = Path.home() / "GitHub/Cerfa-drone"
FILE = ROOT / "backend/src/services/CompanyPilotService.ts"

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup = FILE.with_name(FILE.name + f".bak-pilot-active-{stamp}")

text = FILE.read_text(encoding="utf-8")
shutil.copy2(FILE, backup)

def replace(old, new, label):
    global text
    count = text.count(old)
    if count != 1:
        print(f"❌ {label}: occurrence attendue = 1, trouvée = {count}")
        FILE.write_text(backup.read_text(encoding="utf-8"), encoding="utf-8")
        raise SystemExit(1)
    text = text.replace(old, new, 1)
    print(f"✅ {label}")

replace(
"""                if (existingMembership.is_pilot) {
                    throw new ConflictError(
                        'Cet utilisateur est déjà pilote dans cette entreprise.'
                    );
                }

                await this.companyUsers.setPilot(
                    companyId,
                    existingUser.id,
                    true
                );""",
"""                if (
                    existingMembership.is_pilot &&
                    existingMembership.is_pilot_active
                ) {
                    throw new ConflictError(
                        'Cet utilisateur est déjà pilote dans cette entreprise.'
                    );
                }

                await this.companyUsers.setPilot(
                    companyId,
                    existingUser.id,
                    true
                );""",
"réactivation lors de la création"
)

marker = """    }
}
"""

method = """    }

    // ============================================================
    // RÉACTIVER LE STATUT PILOTE
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
        await this.companyUsers
        .findByCompanyAndUser(
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
            throw new ConflictError(
                'Ce pilote est déjà actif dans cette entreprise.'
            );
        }

        await this.companyUsers.reactivatePilot(
            companyId,
            pilotId
        );
    }
"""

# Remplace uniquement la dernière fermeture de classe.
pos = text.rfind(marker)

if pos == -1:
    print("❌ Fin de classe introuvable.")
    FILE.write_text(backup.read_text(encoding="utf-8"), encoding="utf-8")
    raise SystemExit(1)

text = text[:pos] + method + text[pos + len(marker):]

FILE.write_text(text, encoding="utf-8")

print("=" * 60)
print("✅ ÉTAPE 3 TERMINÉE")
print("=" * 60)
print("CompanyPilotService.ts mis à jour.")
print("• pilote inactif réactivable")
print("• méthode reactivate() ajoutée")
print(f"💾 Backup : {backup}")
