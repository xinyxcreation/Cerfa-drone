import { FastifyReply, FastifyRequest } from 'fastify';
import {
    CreateMissionCategorySchema,
    UpdateMissionCategorySchema
} from '../schemas/company/MissionCategorySchema.js';
import { MissionCategoryRepository } from '../repositories/MissionCategoryRepository.js';
import { AuthorizationError } from '../errors/AuthorizationError.js';

interface AuthPayload {
    sub: string;
    company_id: string;
    role: string;
}

export class CompanyMissionCategoryController {

    private readonly repository =
        new MissionCategoryRepository();

    private checkManagement(role: string): void {
        if (role !== 'OWNER' && role !== 'MANAGER') {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de gérer les catégories.'
            );
        }
    }

    private async validateDrone(
        droneId: string | null | undefined,
        companyId: string
    ): Promise<void> {
        if (!droneId) return;

        const belongs =
            await this.repository.droneBelongsToCompany(
                droneId,
                companyId
            );

        if (!belongs) {
            throw new AuthorizationError(
                'Le drone sélectionné n’appartient pas à votre entreprise ou n’est plus disponible.'
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

        const categories =
            await this.repository.findAll(
                payload.company_id
            );

        reply.send({
            success: true,
            categories
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
            CreateMissionCategorySchema.parse(
                request.body
            );

        await this.validateDrone(
            body.default_drone_id,
            payload.company_id
        );

        const id =
            await this.repository.create(body);

        await this.repository.setDefaultDrone(
            payload.company_id,
            id,
            body.default_drone_id ?? null
        );

        const category =
            await this.repository.findById(
                id,
                payload.company_id
            );

        reply.status(201).send({
            success: true,
            category
        });
    }

    public async update(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const { categoryId } =
            request.params as { categoryId: string };

        const body =
            UpdateMissionCategorySchema.parse(
                request.body
            );

        const existing =
            await this.repository.findById(
                categoryId,
                payload.company_id
            );

        if (!existing) {
            throw new AuthorizationError(
                'Catégorie introuvable.'
            );
        }

        await this.validateDrone(
            body.default_drone_id,
            payload.company_id
        );

        const categoryData = {
            ...body
        };

        delete categoryData.default_drone_id;

        if (Object.keys(categoryData).length > 0) {
            await this.repository.update(
                categoryId,
                categoryData
            );
        }

        if (
            Object.prototype.hasOwnProperty.call(
                body,
                'default_drone_id'
            )
        ) {
            await this.repository.setDefaultDrone(
                payload.company_id,
                categoryId,
                body.default_drone_id ?? null
            );
        }

        const category =
            await this.repository.findById(
                categoryId,
                payload.company_id
            );

        reply.send({
            success: true,
            category
        });
    }

    public async activate(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const { categoryId } =
            request.params as { categoryId: string };

        await this.repository.activate(categoryId);

        reply.send({ success: true });
    }

    public async deactivate(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const { categoryId } =
            request.params as { categoryId: string };

        await this.repository.deactivate(categoryId);

        reply.send({ success: true });
    }

    public async delete(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const { categoryId } =
            request.params as { categoryId: string };

        await this.repository.delete(categoryId);

        reply.send({ success: true });
    }
}
