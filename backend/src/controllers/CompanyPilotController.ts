import {
    FastifyReply,
    FastifyRequest
} from 'fastify';

import {
    CreatePilotSchema
} from '../schemas/company/CreatePilotSchema.js';

import {
    CompanyPilotService
} from '../services/CompanyPilotService.js';

import {
    CompanyUserRepository
} from '../repositories/CompanyUserRepository.js';

import {
    AuthorizationError
} from '../errors/AuthorizationError.js';

interface AuthPayload {

    sub: string;

    company_id: string;

    role: string;
}

export class CompanyPilotController {

    private readonly companyUsers =
    new CompanyUserRepository();

    private readonly service =
    new CompanyPilotService();

    private checkManagementAccess(
        role: string
    ): void {

        if (
            role !== 'OWNER' &&
            role !== 'MANAGER'
        ) {

            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de gérer les pilotes.'
            );
        }
    }

    // ============================================================
    // LISTE DES PILOTES
    // ============================================================

    public async list(
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

        const pilots =
        await this.companyUsers.findPilotsByCompanyId(
            payload.company_id
        );

        reply.send({

            success: true,

            pilots: pilots.map(pilot => ({

                id:
                pilot.user_id,

                email:
                pilot.email,

                first_name:
                pilot.firstname,

                last_name:
                pilot.lastname,

                phone:
                pilot.phone,

                company_name:
                pilot.company_name,

                joined_at:
                pilot.joined_at,

                is_pilot:
                pilot.is_pilot

            }))
        });
    }

    // ============================================================
    // AJOUTER / RATTACHER UN PILOTE
    // ============================================================

    public async create(
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

        const body =
        CreatePilotSchema.parse(
            request.body
        );

        const pilot =
        await this.service.create(
            payload.company_id,
            payload.role,
            body
        );

        reply.code(201).send({

            success: true,

            pilot: {

                id:
                pilot.id,

                email:
                pilot.email,

                first_name:
                pilot.firstname,

                last_name:
                pilot.lastname,

                phone:
                pilot.phone,

                is_pilot:
                pilot.isPilot

            }
        });
    }

    // ============================================================
    // MOI-MÊME : DEVENIR PILOTE
    // ============================================================

    public async activateMe(
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

        await this.service.setCurrentUserPilot(
            payload.company_id,
            payload.sub,
            true
        );

        reply.send({

            success: true,

            is_pilot: true

        });
    }

    // ============================================================
    // MOI-MÊME : NE PLUS ÊTRE PILOTE
    // ============================================================

    public async deactivateMe(
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

        await this.service.setCurrentUserPilot(
            payload.company_id,
            payload.sub,
            false
        );

        reply.send({

            success: true,

            is_pilot: false

        });
    }

    // ============================================================
    // DÉSACTIVER UN AUTRE PILOTE
    // ============================================================

    public async deactivate(
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

        if (
            params.pilotId ===
            payload.sub
        ) {

            throw new AuthorizationError(
                'Utilisez votre propre statut pilote pour modifier votre statut.'
            );
        }

        await this.service.deactivate(
            payload.company_id,
            payload.role,
            params.pilotId
        );

        reply.send({

            success: true

        });
    }
}
