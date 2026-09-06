from pathlib import Path
from datetime import datetime

p = Path("frontend/lib/features/management/models/company_pilot.dart")
text = p.read_text(encoding="utf-8")

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup = p.with_name(p.name + f".bak-pilot-active-fix-{stamp}")
backup.write_text(text, encoding="utf-8")
print(f"💾 Backup : {backup}")

# 1. Constructeur
old = """    required this.role,
    required this.certifications,
  });"""

new = """    required this.role,
    required this.certifications,
    required this.isActive,
  });"""

if old not in text:
    raise SystemExit("❌ Constructeur introuvable")

text = text.replace(old, new, 1)

# 2. Champ
old = """  final String role;
  final List<PilotCertification> certifications;"""

new = """  final String role;
  final List<PilotCertification> certifications;
  final bool isActive;"""

if old not in text:
    raise SystemExit("❌ Déclaration des champs introuvable")

text = text.replace(old, new, 1)

# 3. fromJson
old = """      role: json['role']?.toString().toUpperCase() ?? 'PILOT',
      certifications: certificationData"""

new = """      role: json['role']?.toString().toUpperCase() ?? 'PILOT',
      isActive: json['is_pilot_active'] == true ||
          json['is_pilot_active'] == 1 ||
          json['is_pilot_active']?.toString().toLowerCase() == 'true' ||
          json['is_pilot_active']?.toString() == '1',
      certifications: certificationData"""

if old not in text:
    raise SystemExit("❌ Bloc fromJson introuvable")

text = text.replace(old, new, 1)

p.write_text(text, encoding="utf-8")

print("✅ Constructeur : isActive ajouté")
print("✅ Champ : isActive ajouté")
print("✅ fromJson : is_pilot_active ajouté")
print("============================================================")
print("✅ MODÈLE COMPANY PILOT CORRIGÉ")
print("============================================================")
