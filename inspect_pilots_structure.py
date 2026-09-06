from pathlib import Path

ROOT = Path.home() / "GitHub/Cerfa-drone"

files = [
    ROOT / "backend/src/database/migrations/005_create_company_users.sql",
    ROOT / "backend/src/repositories/CompanyUserRepository.ts",
    ROOT / "backend/src/services/CompanyPilotService.ts",
    ROOT / "backend/src/controllers/CompanyPilotController.ts",
    ROOT / "backend/src/routes/auth.ts",
    ROOT / "backend/src/routes/company.ts",
    ROOT / "frontend/lib/features/management/models/company_pilot.dart",
    ROOT / "frontend/lib/features/management/services/pilots_service.dart",
    ROOT / "frontend/lib/features/management/presentation/management_page.dart",
]

keywords = [
    "findPilotsByCompanyId",
    "countPilotsByCompanyId",
    "deactivatePilot",
    "setPilot",
    "is_pilot",
    "deactivate",
    "reactivate",
    "PilotsService.deactivatePilot",
    "Désactiver",
    "Réactiver",
    "isActive",
]

print("=" * 80)
print("🔎 INSPECTION STRUCTURE PILOTES")
print("=" * 80)

for path in files:
    if not path.exists():
        print(f"\n⚠️ ABSENT : {path}")
        continue

    print("\n" + "=" * 80)
    print(path)
    print("=" * 80)

    lines = path.read_text(encoding="utf-8").splitlines()

    found = False

    for i, line in enumerate(lines):
        if any(keyword in line for keyword in keywords):
            found = True

            start = max(0, i - 5)
            end = min(len(lines), i + 8)

            print(f"\n--- lignes {start + 1}-{end} ---")

            for n in range(start, end):
                print(f"{n + 1:4}: {lines[n]}")

    if not found:
        print("Aucun motif intéressant trouvé.")

print()
print("=" * 80)
print("✅ INSPECTION TERMINÉE")
print("=" * 80)
