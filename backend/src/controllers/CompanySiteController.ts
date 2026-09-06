import { FastifyReply, FastifyRequest } from 'fastify';
import {
    CreateSiteSchema,
    UpdateSiteSchema
} from '../schemas/company/SiteSchema.js';
import { SiteRepository } from '../repositories/SiteRepository.js';
import { AuthorizationError } from '../errors/AuthorizationError.js';

interface AuthPayload {
    sub: string;
    company_id: string;
    role: string;
}

export class CompanySiteController {

    private readonly repository =
        new SiteRepository();

    private checkManagement(role: string): void {
        if (role !== 'OWNER' && role !== 'MANAGER') {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de gérer les sites.'
            );
        }
    }

    public async list(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const sites =
            await this.repository.findAll(
                payload.company_id
            );

        reply.send({
            success: true,
            sites
        });
    }

    public async create(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const body =
            CreateSiteSchema.parse(request.body);

        const id =
            await this.repository.create(
                payload.company_id,
                body
            );

        const site =
            await this.repository.findById(
                payload.company_id,
                id
            );

        reply.status(201).send({
            success: true,
            site
        });
    }

    public async update(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const { siteId } =
            request.params as { siteId: string };

        const existing =
            await this.repository.findById(
                payload.company_id,
                siteId
            );

        if (!existing) {
            throw new AuthorizationError(
                'Site introuvable.'
            );
        }

        const body =
            UpdateSiteSchema.parse(request.body);

        await this.repository.update(
            siteId,
            body
        );

        const site =
            await this.repository.findById(
                payload.company_id,
                siteId
            );

        reply.send({
            success: true,
            site
        });
    }
}
