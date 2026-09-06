from pathlib import Path
from datetime import datetime
import shutil

path = Path("frontend/lib/features/management/services/pilots_service.dart")

if not path.exists():
    raise SystemExit(f"❌ Fichier introuvable : {path}")

text = path.read_text(encoding="utf-8")

if "static Future<void> reactivatePilot" in text:
    print("ℹ️ reactivatePilot() existe déjà.")
else:
    marker = "  static Future<void> deactivatePilot(String pilotId) async {"

    if marker not in text:
        raise SystemExit("❌ Impossible de trouver deactivatePilot().")

    backup = path.with_name(
        f"{path.stem}.bak-pilot-reactivate-{datetime.now():%Y%m%d-%H%M%S}{path.suffix}"
    )
    shutil.copy2(path, backup)

    method = """  static Future<void> reactivatePilot(String pilotId) async {
    try {
      await ApiClient.instance.patch('/auth/company/pilots/$pilotId/activate');
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(error, 'Impossible de réactiver le pilote.'),
      );
    }
  }

"""

    text = text.replace(marker, method + marker, 1)
    path.write_text(text, encoding="utf-8")

    print(f"💾 Backup : {backup}")

print()
print("============================================================")
print("✅ ÉTAPE 8A TERMINÉE")
print("============================================================")
print("reactivatePilot() ajouté au service Flutter.")
