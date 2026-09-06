from pathlib import Path
from datetime import datetime
import shutil
import re

path = Path("backend/src/controllers/CompanyPilotController.ts")

if not path.exists():
    raise SystemExit(f"❌ Fichier introuvable : {path}")

text = path.read_text(encoding="utf-8")

if re.search(r"is_pilot_active\s*:", text):
    print("ℹ️ is_pilot_active est déjà présent dans le contrôleur.")
else:
    # On cible uniquement le premier mapping de la liste des pilotes.
    pattern = r"(is_pilot\s*:\s*\n\s*pilot\.is_pilot\s*,)"

    match = re.search(pattern, text)

    if not match:
        raise SystemExit(
            "❌ Impossible de trouver le mapping pilot.is_pilot. "
            "Aucun fichier modifié."
        )

    backup = path.with_name(
        f"{path.stem}.bak-pilot-status-{datetime.now():%Y%m%d-%H%M%S}{path.suffix}"
    )
    shutil.copy2(path, backup)

    replacement = (
        match.group(1)
        + "\n\n"
        + "                    is_pilot_active:\n"
        + "                    pilot.is_pilot_active,"
    )

    text = text[:match.start()] + replacement + text[match.end():]

    path.write_text(text, encoding="utf-8")

    print(f"💾 Backup : {backup}")
    print("✅ is_pilot_active ajouté à la réponse API.")

print()
print("============================================================")
print("✅ ÉTAPE 12A TERMINÉE")
print("============================================================")
