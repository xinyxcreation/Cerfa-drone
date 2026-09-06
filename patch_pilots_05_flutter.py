from pathlib import Path
from datetime import datetime

ROOT = Path.home() / "GitHub" / "Cerfa-drone" / "frontend"

model = ROOT / "lib/features/management/models/company_pilot.dart"
service = ROOT / "lib/features/management/services/pilots_service.dart"

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")

def backup(path):
    backup = path.with_name(path.name + f".bak-pilot-active-{stamp}")
    backup.write_text(path.read_text(), encoding="utf-8")
    print(f"💾 Backup : {backup}")
    return backup

# ============================================================
# MODÈLE
# ============================================================

text = model.read_text(encoding="utf-8")
backup(model)

old = """    required this.role,
    required this.certifications,
  });

  final String id;"""

new = """    required this.role,
    required this.certifications,
    required this.isActive,
  });

  final String id;"""

if old not in text:
    raise SystemExit("❌ Modèle : constructeur introuvable")

text = text.replace(old, new, 1)

old = """  final String role;
  final List<PilotCertification> certifications;"""

new = """  final String role;
  final List<PilotCertification> certifications;
  final bool isActive;"""

if old not in text:
    raise SystemExit("❌ Modèle : champs introuvables")

text = text.replace(old, new, 1)

old = """      role: json['role']?.toString().toUpperCase() ?? 'PILOT',
      certifications:"""

new = """      role: json['role']?.toString().toUpperCase() ?? 'PILOT',
      isActive: json['is_pilot_active'] == true ||
          json['is_pilot_active'] == 1 ||
          json['is_pilot_active']?.toString().toLowerCase() == 'true' ||
          json['is_pilot_active']?.toString() == '1',
      certifications:"""

if old not in text:
    raise SystemExit("❌ Modèle : fromJson introuvable")

text = text.replace(old, new, 1)

model.write_text(text, encoding="utf-8")

print("✅ CompanyPilot : isActive ajouté")

# ============================================================
# SERVICE
# ============================================================

text = service.read_text(encoding="utf-8")
backup(service)

marker = """  static Future<void> deactivatePilot(
    String pilotId,
  ) async {
"""

if marker not in text:
    raise SystemExit("❌ Service : deactivatePilot introuvable")

method = """  static Future<void> reactivatePilot(
    String pilotId,
  ) async {
    try {
      await ApiClient.instance.patch(
        '/auth/company/pilots/$pilotId/activate',
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

text = text.replace(marker, method + marker, 1)

service.write_text(text, encoding="utf-8")

print("✅ PilotsService : reactivatePilot() ajouté")

print()
print("=" * 60)
print("✅ ÉTAPE 5 TERMINÉE")
print("=" * 60)
print("• CompanyPilot.isActive ajouté")
print("• lecture de is_pilot_active ajoutée")
print("• PilotsService.reactivatePilot() ajouté")
print()
