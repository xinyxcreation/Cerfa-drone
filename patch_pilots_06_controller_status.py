from pathlib import Path
from datetime import datetime

p = Path("backend/src/controllers/CompanyPilotController.ts")
text = p.read_text(encoding="utf-8")

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup = p.with_name(p.name + f".bak-pilot-active-status-{stamp}")
backup.write_text(text, encoding="utf-8")
print(f"💾 Backup : {backup}")

old = """                    is_pilot:
                    pilot.is_pilot,

                    certifications:"""

new = """                    is_pilot:
                    pilot.is_pilot,

                    is_pilot_active:
                    pilot.is_pilot_active,

                    certifications:"""

if old not in text:
    raise SystemExit("❌ Bloc is_pilot introuvable")

text = text.replace(old, new, 1)

p.write_text(text, encoding="utf-8")

print("✅ is_pilot_active ajouté à GET /auth/company/pilots")
print("=" * 60)
print("✅ ÉTAPE 6 TERMINÉE")
print("=" * 60)
