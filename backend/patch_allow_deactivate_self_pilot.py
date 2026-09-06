from pathlib import Path
import shutil
import subprocess
import sys
from datetime import datetime

ROOT = Path.cwd()
FILE = ROOT / "src/controllers/CompanyPilotController.ts"

print("🚀 CORRECTION DÉSACTIVATION PILOTE")
print("=" * 60)

if not FILE.exists():
    raise RuntimeError(f"❌ Fichier introuvable : {FILE}")

text = FILE.read_text(encoding="utf-8")

backup = FILE.with_name(
    f"{FILE.name}.bak-self-deactivate-{datetime.now():%Y%m%d-%H%M%S}"
)

shutil.copy2(FILE, backup)

try:
    # ============================================================
    # Cibler STRICTEMENT deactivate()
    # ============================================================

    class_start = text.find(
        "export class CompanyPilotController"
    )

    method_start = text.find(
        "public async deactivate(",
        class_start,
    )

    if class_start == -1 or method_start == -1:
        raise RuntimeError(
            "❌ Méthode deactivate() introuvable."
        )

    method_end = text.find(
        "\n    }\n}",
        method_start,
    )

    if method_end == -1:
        raise RuntimeError(
            "❌ Fin de deactivate() introuvable."
        )

    method = text[method_start:method_end]

    # ============================================================
    # Supprimer UNIQUEMENT l'interdiction de soi-même
    # ============================================================

    forbidden = """        if (
            params.pilotId ===
            payload.sub
        ) {

            throw new AuthorizationError(
                'Utilisez votre propre statut pilote pour modifier votre statut.'
            );
        }

"""

    if forbidden not in method:
        raise RuntimeError(
            "❌ Bloc d'interdiction du pilote courant introuvable."
        )

    method = method.replace(
        forbidden,
        "",
        1,
    )

    text = (
        text[:method_start]
        + method
        + text[method_end:]
    )

    FILE.write_text(text, encoding="utf-8")

    print("✅ interdiction de désactiver son propre profil supprimée")

    # ============================================================
    # Vérification
    # ============================================================

    new_text = FILE.read_text(encoding="utf-8")

    if (
        "Utilisez votre propre statut pilote pour modifier votre statut."
        in new_text
    ):
        raise RuntimeError(
            "❌ L'ancien bloc est toujours présent."
        )

    if "await this.service.deactivate(" not in new_text:
        raise RuntimeError(
            "❌ Appel du service deactivate() absent."
        )

    print("✅ vérifications OK")

    # ============================================================
    # TypeScript
    # ============================================================

    print("\n🔍 Vérification TypeScript")

    # Le package backend utilise normalement tsc.
    package_json = ROOT / "package.json"

    if package_json.exists():
        import json

        package = json.loads(
            package_json.read_text(encoding="utf-8")
        )

        scripts = package.get("scripts", {})

        if "build" in scripts:
            result = subprocess.run(
                ["npm", "run", "build"],
                cwd=ROOT,
            )
        else:
            result = subprocess.run(
                ["npx", "tsc", "--noEmit"],
                cwd=ROOT,
            )

        if result.returncode != 0:
            raise RuntimeError(
                "❌ Vérification TypeScript échouée."
            )

        print("✅ TypeScript OK")

    else:
        print("⚠️ package.json introuvable, vérification ignorée")

except Exception as error:

    print(f"\n❌ {error}")
    print("↩️ Restauration automatique...")

    shutil.copy2(backup, FILE)

    print("✅ fichier restauré")
    print(f"💾 Backup : {backup}")

    sys.exit(1)

print("\n" + "=" * 60)
print("✅ BACKEND CORRIGÉ")
print("=" * 60)

print("""
OWNER / MANAGER
       ↓
Pilote appartient à l'entreprise ?
       ↓
      OUI
       ↓
Désactivation autorisée

Cela fonctionne maintenant aussi pour
le pilote correspondant à votre propre compte.
""")

print(f"💾 Backup : {backup}")
