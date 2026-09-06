import { FastifyReply, FastifyRequest } from 'fastify';
import {
    CreateClientSchema,
    UpdateClientSchema
} from '../schemas/company/ClientSchema.js';
import { ClientRepository } from '../repositories/ClientRepository.js';
import { AuthorizationError } from '../errors/AuthorizationError.js';

interface AuthPayload {
    sub: string;
    company_id: string;
    role: string;
}

export class CompanyClientController {

    private readonly repository =
        new ClientRepository();

    private checkManagement(role: string): void {
        if (role !== 'OWNER' && role !== 'MANAGER') {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de gérer les clients.'
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

        const clients =
            await this.repository.findAll(
                payload.company_id
            );

        reply.send({
            success: true,
            clients
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
            CreateClientSchema.parse(request.body);

        const id =
            await this.repository.create(
                payload.company_id,
                body
            );

        const client =
            await this.repository.findById(
                payload.company_id,
                id
            );

        reply.status(201).send({
            success: true,
            client
        });
    }

    public async update(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const { clientId } =
            request.params as { clientId: string };

        const existing =
            await this.repository.findById(
                payload.company_id,
                clientId
            );

        if (!existing) {
            throw new AuthorizationError(
                'Client introuvable.'
            );
        }

        const body =
            UpdateClientSchema.parse(request.body);

        await this.repository.update(
            clientId,
            body
        );

        const client =
            await this.repository.findById(
                payload.company_id,
                clientId
            );

        reply.send({
            success: true,
            client
        });
    }
}
