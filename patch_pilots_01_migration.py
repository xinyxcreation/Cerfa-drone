from pathlib import Path
from datetime import datetime
import shutil

ROOT = Path.home() / "GitHub/Cerfa-drone"
FILE = ROOT / "backend/src/database/migrations/005_create_company_users.sql"

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup = FILE.with_name(FILE.name + f".bak-pilot-active-{stamp}")

text = FILE.read_text(encoding="utf-8")

if "is_pilot_active" in text:
    print("⚠️ is_pilot_active existe déjà.")
    raise SystemExit(0)

shutil.copy2(FILE, backup)

old = """    is_pilot BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,"""

new = """    is_pilot BOOLEAN NOT NULL DEFAULT FALSE,
    is_pilot_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,"""

if old not in text:
    print("❌ Structure attendue introuvable.")
    print(f"↩️ Backup conservé : {backup}")
    raise SystemExit(1)

text = text.replace(old, new, 1)

old_index = """    INDEX idx_company_users_pilot (is_pilot),
    INDEX idx_company_users_active (is_active),"""

new_index = """    INDEX idx_company_users_pilot (is_pilot),
    INDEX idx_company_users_pilot_active (is_pilot_active),
    INDEX idx_company_users_active (is_active),"""

if old_index not in text:
    print("❌ Bloc des index introuvable.")
    FILE.write_text(backup.read_text(encoding="utf-8"), encoding="utf-8")
    raise SystemExit(1)

text = text.replace(old_index, new_index, 1)

FILE.write_text(text, encoding="utf-8")

print("=" * 60)
print("✅ ÉTAPE 1 TERMINÉE")
print("=" * 60)
print("Migration 005 modifiée.")
print("Ajout : is_pilot_active BOOLEAN")
print("Index : idx_company_users_pilot_active")
print(f"💾 Backup : {backup}")
