from pathlib import Path
from datetime import datetime
import shutil

path = Path("frontend/lib/features/management/services/pilots_service.dart")

text = path.read_text(encoding="utf-8")

marker = "      final data = Map<String, dynamic>.from(response.data as Map);"

if "DEBUG PILOTS API" in text:
    print("ℹ️ Debug déjà présent.")
else:
    if marker not in text:
        raise SystemExit("❌ Marqueur getPilots introuvable.")

    backup = path.with_name(
        f"{path.stem}.bak-debug-api-{datetime.now():%Y%m%d-%H%M%S}{path.suffix}"
    )
    shutil.copy2(path, backup)

    replacement = """      print('========== DEBUG PILOTS API ==========');
      print(response.data);
      print('======================================');

""" + marker

    text = text.replace(marker, replacement, 1)
    path.write_text(text, encoding="utf-8")

    print(f"💾 Backup : {backup}")
    print("✅ Debug API ajouté.")

