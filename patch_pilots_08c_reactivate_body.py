from pathlib import Path
from datetime import datetime
import shutil

path = Path("frontend/lib/features/management/services/pilots_service.dart")

text = path.read_text(encoding="utf-8")

old = """      await ApiClient.instance.patch('/auth/company/pilots/$pilotId/activate');"""

new = """      await ApiClient.instance.patch(
        '/auth/company/pilots/$pilotId/activate',
        data: {},
      );"""

if old not in text:
    if "data: {}" in text and "company/pilots/$pilotId/activate" in text:
        print("ℹ️ reactivatePilot() semble déjà corrigé.")
    else:
        raise SystemExit("❌ Appel PATCH de réactivation introuvable.")
else:
    backup = path.with_name(
        f"{path.stem}.bak-pilot-reactivate-body-{datetime.now():%Y%m%d-%H%M%S}{path.suffix}"
    )
    shutil.copy2(path, backup)

    text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")

    print(f"💾 Backup : {backup}")
    print("✅ data: {} ajouté à reactivatePilot().")

print()
print("============================================================")
print("✅ ÉTAPE 8C TERMINÉE")
print("============================================================")
