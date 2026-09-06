from pathlib import Path
from datetime import datetime
import shutil

ROOT = Path.home() / "GitHub/Cerfa-drone"

CONTROLLER = ROOT / "backend/src/controllers/CompanyPilotController.ts"
ROUTES = ROOT / "backend/src/routes/auth.ts"

stamp = datetime.now().strftime("%Y%m%d-%H%M%S")

backup_controller = CONTROLLER.with_name(
    CONTROLLER.name + f".bak-pilot-active-{stamp}"
)
backup_routes = ROUTES.with_name(
    ROUTES.name + f".bak-pilot-active-{stamp}"
)

controller = CONTROLLER.read_text(encoding="utf-8")
routes = ROUTES.read_text(encoding="utf-8")

shutil.copy2(CONTROLLER, backup_controller)
shutil.copy2(ROUTES, backup_routes)


# ============================================================
# CONTROLLER
# ============================================================

marker = """    }
}"""

method = """    }

    // ============================================================
    // RÉACTIVER UN PILOTE
    // ============================================================

    public async reactivate(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
        await request.jwtVerify<AuthPayload>();

        if (!payload.company_id) {

            throw new AuthorizationError(
                'Entreprise introuvable dans la session.'
            );
        }

        this.checkManagementAccess(
            payload.role
        );

        const params =
        request.params as {
            pilotId: string;
        };

        await this.service.reactivate(
            payload.company_id,
            payload.role,
            params.pilotId
        );

        reply.send({

            success: true

        });
    }
"""

pos = controller.rfind(marker)

if pos == -1:
    print("❌ Fin de CompanyPilotController introuvable.")
    raise SystemExit(1)

controller = (
    controller[:pos]
    + method
    + controller[pos + len(marker):]
)

print("✅ Controller : reactivate() ajouté")


# ============================================================
# ROUTE
# ============================================================

old_route = """    app.delete(
        '/company/pilots/:pilotId',
        {
            preHandler: async request => {
                await request.jwtVerify();
            }
        },
        pilotController.deactivate.bind(
            pilotController
        )
    );"""

new_route = """    app.delete(
        '/company/pilots/:pilotId',
        {
            preHandler: async request => {
                await request.jwtVerify();
            }
        },
        pilotController.deactivate.bind(
            pilotController
        )
    );

    app.patch(
        '/company/pilots/:pilotId/activate',
        {
            preHandler: async request => {
                await request.jwtVerify();
            }
        },
        pilotController.reactivate.bind(
            pilotController
        )
    );"""

if routes.count(old_route) != 1:
    print(
        "❌ Route désactivation pilote : "
        f"occurrence attendue = 1, trouvée = {routes.count(old_route)}"
    )

    CONTROLLER.write_text(
        backup_controller.read_text(encoding="utf-8"),
        encoding="utf-8"
    )

    ROUTES.write_text(
        backup_routes.read_text(encoding="utf-8"),
        encoding="utf-8"
    )

    raise SystemExit(1)

routes = routes.replace(old_route, new_route, 1)

print("✅ Route PATCH /company/pilots/:pilotId/activate ajoutée")


CONTROLLER.write_text(controller, encoding="utf-8")
ROUTES.write_text(routes, encoding="utf-8")

print("=" * 60)
print("✅ ÉTAPE 4 TERMINÉE")
print("=" * 60)
print("• Controller reactivate ajouté")
print("• Route PATCH /company/pilots/:pilotId/activate ajoutée")
print(f"💾 Backup controller : {backup_controller}")
print(f"💾 Backup routes     : {backup_routes}")
