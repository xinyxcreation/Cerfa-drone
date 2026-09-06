from pathlib import Path
from datetime import datetime
import shutil

ROOT = Path.home() / "GitHub/Cerfa-drone"
FILE = ROOT / "backend/src/repositories/CompanyUserRepository.ts"

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup = FILE.with_name(FILE.name + f".bak-pilot-active-{stamp}")

text = FILE.read_text(encoding="utf-8")
shutil.copy2(FILE, backup)

def replace(old, new, label):
    global text
    count = text.count(old)
    if count != 1:
        print(f"❌ {label}: occurrence attendue = 1, trouvée = {count}")
        FILE.write_text(backup.read_text(encoding="utf-8"), encoding="utf-8")
        raise SystemExit(1)
    text = text.replace(old, new, 1)
    print(f"✅ {label}")

replace(
"""    is_pilot: boolean;
    is_active: boolean;""",
"""    is_pilot: boolean;
    is_pilot_active: boolean;
    is_active: boolean;""",
"interface CompanyUser"
)

replace(
"""    is_pilot: boolean;
    company_name: string;""",
"""    is_pilot: boolean;
    is_pilot_active: boolean;
    company_name: string;""",
"interface CompanyMember"
)

replace(
"""            AND is_pilot = TRUE
            AND is_active = TRUE""",
"""            AND is_pilot = TRUE
            AND is_pilot_active = TRUE
            AND is_active = TRUE""",
"countPilotsByCompanyId"
)

start = text.index(
    "    public async findPilotsByCompanyId("
)
end = text.index(
    "    public async create(",
    start,
)

block = text[start:end]

old = """                    cu.is_pilot
"""
new = """                    cu.is_pilot,
                    cu.is_pilot_active
"""

if block.count(old) != 1:
    print(
        "❌ findPilots SELECT: occurrence attendue = 1, "
        f"trouvée = {block.count(old)}"
    )
    FILE.write_text(backup.read_text(encoding="utf-8"), encoding="utf-8")
    raise SystemExit(1)

block = block.replace(old, new, 1)
text = text[:start] + block + text[end:]

print("✅ findPilotsByCompanyId")

replace(
"""                is_pilot: isPilot,
                is_active: true,""",
"""                is_pilot: isPilot,
                is_pilot_active: isPilot,
                is_active: true,""",
"create"
)

replace(
"""            {
                is_pilot: isPilot
            }
        );
    }

    public async deactivatePilot(""",
"""            {
                is_pilot: isPilot,
                is_pilot_active: isPilot
            }
        );
    }

    public async deactivatePilot(""",
"setPilot"
)

replace(
"""            {
                is_pilot: false
            }
        );
    }

    public async deactivate(
""",
"""            {
                is_pilot_active: false
            }
        );
    }

    public async reactivatePilot(
        companyId: string,
        userId: string
    ): Promise<void> {

        const membership =
        await this.findByCompanyAndUser(
            companyId,
            userId
        );

        if (!membership) {
            throw new Error(
                'Utilisateur non associé à cette entreprise.'
            );
        }

        await this.baseUpdate(
            this.table,
            membership.id,
            {
                is_pilot: true,
                is_pilot_active: true
            }
        );
    }

    public async deactivate(
""",
"deactivatePilot + reactivatePilot"
)

replace(
"""            {
                is_active: false,
                is_pilot: false,
                left_at: new Date()
            }""",
"""            {
                is_active: false,
                is_pilot_active: false,
                left_at: new Date()
            }""",
"deactivate membre"
)

FILE.write_text(text, encoding="utf-8")

print("=" * 60)
print("✅ ÉTAPE 2 TERMINÉE")
print("=" * 60)
print("CompanyUserRepository.ts mis à jour.")
print("• is_pilot_active ajouté")
print("• pilotes inactifs conservés dans la liste")
print("• comptage = pilotes actifs uniquement")
print("• désactivation = is_pilot_active=false")
print("• réactivation ajoutée")
print(f"💾 Backup : {backup}")
