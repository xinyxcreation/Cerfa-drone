import {
    FastifyReply,
    FastifyRequest
} from 'fastify';

import {
    CreateDroneSchema,
    UpdateDroneSchema
} from '../schemas/company/DroneSchema.js';

import {
    DroneRepository
} from '../repositories/DroneRepository.js';

import {
    AuthorizationError
} from '../errors/AuthorizationError.js';

interface AuthPayload {
    sub: string;
    company_id: string;
    role: string;
}

export class CompanyDroneController {

    private readonly repository =
        new DroneRepository();

    private checkManagementAccess(
        role: string
    ): void {

        if (
            role !== 'OWNER' &&
            role !== 'MANAGER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de gérer les drones.'
            );
        }
    }

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

        const drones =
            await this.repository.findByCompanyId(
                payload.company_id
            );

        reply.send({
            success: true,
            drones
        });
    }

    public async get(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagementAccess(
            payload.role
        );

        const { droneId } =
            request.params as { droneId: string };

        const drone =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                droneId
            );

        if (!drone) {
            throw new AuthorizationError(
                'Drone introuvable dans cette entreprise.'
            );
        }

        reply.send({
            success: true,
            drone
        });
    }

    public async create(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagementAccess(
            payload.role
        );

        const body =
            CreateDroneSchema.parse(
                request.body
            );

        const serialNumber =
            body.serial_number.trim();

        const alphaTangoAircraftNumber =
            body.alphatango_aircraft_number.trim();

        const previouslyDeletedSerial =
            await this.repository
                .findDeletedByCompanyAndSerialNumber(
                    payload.company_id,
                    serialNumber
                );

        const previouslyDeletedAlphaTango =
            await this.repository
                .findDeletedByCompanyAndAlphaTango(
                    payload.company_id,
                    alphaTangoAircraftNumber
                );

        const id =
            await this.repository.create(
                payload.company_id,
                {
                    nickname:
                        body.nickname?.trim() || null,

                    manufacturer:
                        body.manufacturer.trim(),

                    model:
                        body.model.trim(),

                    serial_number:
                        serialNumber,

                    alphatango_aircraft_number:
                        alphaTangoAircraftNumber,

                    drone_class:
                        body.drone_class?.trim() || null,

                    weight_g:
                        body.weight_g ?? null,

                    notes:
                        body.notes?.trim() || null
                }
            );

        const drone =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                id
            );

        const warning =
            previouslyDeletedSerial &&
            previouslyDeletedAlphaTango
                ? {
                    type:
                        'serial_number_and_alphatango_reused',
                    message:
                        'Le numéro de série et le numéro AlphaTango ont déjà été utilisés par d’anciens drones. Vérifiez qu’il s’agit bien du même appareil.'
                }
                : previouslyDeletedSerial
                    ? {
                        type:
                            'serial_number_reused',
                        message:
                            'Ce numéro de série a déjà été utilisé par un ancien drone. Vérifiez qu’il s’agit bien du même appareil.'
                    }
                    : previouslyDeletedAlphaTango
                        ? {
                            type:
                                'alphatango_reused',
                            message:
                                'Ce numéro AlphaTango a déjà été utilisé par un ancien drone. Vérifiez qu’il s’agit bien du même appareil.'
                        }
                        : null;

        reply.code(201).send({
            success: true,
            drone,
            ...(warning
                ? { warning }
                : {})
        });
    }

    public async update(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagementAccess(
            payload.role
        );

        const { droneId } =
            request.params as { droneId: string };

        const existing =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                droneId
            );

        if (!existing) {
            throw new AuthorizationError(
                'Drone introuvable dans cette entreprise.'
            );
        }

        const body =
            UpdateDroneSchema.parse(
                request.body
            );

        await this.repository.update(
            payload.company_id,
            droneId,
            {
                ...(body.nickname !== undefined
                    ? {
                        nickname:
                            body.nickname?.trim() || null
                    }
                    : {}),

                ...(body.manufacturer !== undefined
                    ? {
                        manufacturer:
                            body.manufacturer.trim()
                    }
                    : {}),

                ...(body.model !== undefined
                    ? {
                        model:
                            body.model.trim()
                    }
                    : {}),

                ...(body.serial_number !== undefined
                    ? {
                        serial_number:
                            body.serial_number.trim()
                    }
                    : {}),

                ...(body.alphatango_aircraft_number !== undefined
                    ? {
                        alphatango_aircraft_number:
                            body.alphatango_aircraft_number.trim()
                    }
                    : {}),

                ...(body.drone_class !== undefined
                    ? {
                        drone_class:
                            body.drone_class?.trim() || null
                    }
                    : {}),

                ...(body.weight_g !== undefined
                    ? {
                        weight_g:
                            body.weight_g ?? null
                    }
                    : {}),

                ...(body.notes !== undefined
                    ? {
                        notes:
                            body.notes?.trim() || null
                    }
                    : {})
            }
        );

        const drone =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                droneId
            );

        reply.send({
            success: true,
            drone
        });
    }

    public async activate(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagementAccess(
            payload.role
        );

        const { droneId } =
            request.params as { droneId: string };

        const existing =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                droneId
            );

        if (!existing) {
            throw new AuthorizationError(
                'Drone introuvable dans cette entreprise.'
            );
        }

        await this.repository.activate(
            payload.company_id,
            droneId
        );

        reply.send({
            success: true
        });
    }

    public async deactivate(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagementAccess(
            payload.role
        );

        const { droneId } =
            request.params as { droneId: string };

        const existing =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                droneId
            );

        if (!existing) {
            throw new AuthorizationError(
                'Drone introuvable dans cette entreprise.'
            );
        }

        await this.repository.deactivate(
            payload.company_id,
            droneId
        );

        reply.send({
            success: true
        });
    }
    public async delete(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagementAccess(
            payload.role
        );

        const { droneId } =
            request.params as { droneId: string };

        const existing =
            await this.repository.findByCompanyAndId(
                payload.company_id,
                droneId
            );

        if (!existing) {
            throw new AuthorizationError(
                'Drone introuvable dans cette entreprise.'
            );
        }

        await this.repository.delete(
            payload.company_id,
            droneId
        );

        reply.send({
            success: true
        });
    }


}
