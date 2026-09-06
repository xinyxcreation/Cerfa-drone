from pathlib import Path
from datetime import datetime

p = Path("backend/src/services/CompanyPilotService.ts")
text = p.read_text(encoding="utf-8")

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup = p.with_name(p.name + f".bak-reactivate-fix-{stamp}")
backup.write_text(text, encoding="utf-8")
print(f"💾 Backup : {backup}")

if "public async reactivate(" in text:
    print("✅ reactivate() existe déjà")
else:
    marker = """    public async deactivate(
        companyId: string,
        requesterRole: string,
        pilotId: string
    ): Promise<void> {
"""

    if marker not in text:
        raise SystemExit("❌ Méthode deactivate introuvable")

    method = """    public async reactivate(
        companyId: string,
        requesterRole: string,
        pilotId: string
    ): Promise<void> {

        if (
            requesterRole !== 'OWNER' &&
            requesterRole !== 'MANAGER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de réactiver un pilote.'
            );
        }

        const company =
        await this.companies.findById(
            companyId
        );

        if (!company) {
            throw new NotFoundError(
                'Entreprise introuvable.'
            );
        }

        if (!company.is_active) {
            throw new AuthorizationError(
                'Entreprise désactivée.'
            );
        }

        const membership =
        await this.companyUsers
        .findByCompanyAndUser(
            companyId,
            pilotId
        );

        if (!membership) {
            throw new NotFoundError(
                'Utilisateur introuvable dans cette entreprise.'
            );
        }

        if (!membership.is_pilot) {
            throw new NotFoundError(
                'Cet utilisateur n’est pas pilote dans cette entreprise.'
            );
        }

        await this.companyUsers.reactivatePilot(
            companyId,
            pilotId
        );
    }

"""

    text = text.replace(marker, method + marker, 1)
    p.write_text(text, encoding="utf-8")

    print("✅ reactivate() ajouté au service")

opens = text.count("{")
closes = text.count("}")

print(f"Accolades : {{={opens} }}={closes}")

if opens != closes:
    raise SystemExit("❌ Accolades déséquilibrées")

print("✅ Accolades équilibrées")
