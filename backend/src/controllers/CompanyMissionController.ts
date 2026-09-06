import {
    FastifyReply,
    FastifyRequest
} from 'fastify';

import {
    AuthorizationError
} from '../errors/AuthorizationError.js';

import {
    NotFoundError
} from '../errors/NotFoundError.js';

import {
    CreateMissionSchema,
    UpdateMissionSchema,
    UpdateMissionStatusSchema
} from '../schemas/company/MissionSchema.js';

import {
    MissionRepository
} from '../repositories/MissionRepository.js';

interface AuthPayload {

    sub: string;
    company_id: string;
    role: string;

}

export class CompanyMissionController {

    private readonly repository =
        new MissionRepository();

    private checkAccess(
        role: string
    ): void {

        if (
            role !== 'OWNER' &&
            role !== 'MANAGER' &&
            role !== 'USER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas accès aux missions.'
            );
        }
    }

    private checkManagement(
        role: string
    ): void {

        if (
            role !== 'OWNER' &&
            role !== 'MANAGER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de gérer les missions.'
            );
        }
    }

    // ============================================================
    // LISTE
    // ============================================================

    public async list(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkAccess(payload.role);

        const missions =
            await this.repository.findAll(
                payload.company_id
            );

        reply.send({
            success: true,
            missions
        });
    }

    // ============================================================
    // REFERENTIELS
    // ============================================================

    public async references(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkAccess(payload.role);

        const [
            clients,
            pilots,
            drones,
            categories,
            statuses,
            prefectures
        ] = await Promise.all([

            this.repository.findClients(
                payload.company_id
            ),

            this.repository.findPilots(
                payload.company_id
            ),

            this.repository.findDrones(
                payload.company_id
            ),

            this.repository.findCategories(),

            this.repository.findStatuses(),

            this.repository.findPrefectures()

        ]);

        reply.send({
            success: true,
            clients,
            pilots,
            drones,
            categories,
            statuses,
            prefectures
        });
    }

    // ============================================================
    // DETAIL
    // ============================================================

    public async get(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkAccess(payload.role);

        const {
            missionId
        } = request.params as {
            missionId: string
        };

        const mission =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        if (!mission) {
            throw new NotFoundError(
                'Mission introuvable.'
            );
        }

        const location =
            await this.repository.findLocation(
                missionId
            );

        reply.send({
            success: true,
            mission,
            location
        });
    }

    // ============================================================
    // CREATION
    // ============================================================

    public async create(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const body =
            CreateMissionSchema.parse(
                request.body
            );

        const validClient =
            await this.repository.clientBelongsToCompany(
                payload.company_id,
                body.client_id
            );

        if (!validClient) {
            throw new AuthorizationError(
                'Client introuvable dans cette entreprise.'
            );
        }

        const validPilot =
            await this.repository.pilotBelongsToCompany(
                payload.company_id,
                body.pilot_id
            );

        if (!validPilot) {
            throw new AuthorizationError(
                'Pilote actif introuvable dans cette entreprise.'
            );
        }

        const validDrone =
            await this.repository.droneBelongsToCompany(
                payload.company_id,
                body.location.drone_id
            );

        if (!validDrone) {
            throw new AuthorizationError(
                'Drone actif introuvable dans cette entreprise.'
            );
        }

        if (
            !(await this.repository.categoryExists(
                body.category_id
            ))
        ) {
            throw new NotFoundError(
                'Catégorie de mission introuvable.'
            );
        }

        let statusId =
            body.mission_status_id;

        if (!statusId) {

            const statuses =
                await this.repository.findStatuses();

            if (statuses.length === 0) {
                throw new NotFoundError(
                    'Aucun statut de mission disponible.'
                );
            }

            statusId =
                statuses[0].id as string;
        }

        if (
            !(await this.repository.statusExists(
                statusId
            ))
        ) {
            throw new NotFoundError(
                'Statut de mission introuvable.'
            );
        }

        if (
            !(await this.repository.prefectureExists(
                body.location.prefecture_id
            ))
        ) {
            throw new NotFoundError(
                'Préfecture introuvable.'
            );
        }

        const missionId =
            await this.repository.create(
                payload.company_id,
                {
                    client_id:
                        body.client_id,

                    pilot_id:
                        body.pilot_id,

                    category_id:
                        body.category_id,

                    mission_status_id:
                        statusId,

                    reference:
                        body.reference?.trim() ||
                        `M-${Date.now()}`,

                    title:
                        body.title.trim(),

                    description:
                        body.description?.trim() ||
                        null,

                    planned_at:
                        body.planned_at
                            ? new Date(
                                body.planned_at
                            )
                            : null,

                    notes:
                        body.notes?.trim() ||
                        null,

                    location: {

                        site_id:
                            body.location.site_id ??
                            null,

                        drone_id:
                            body.location.drone_id,

                        prefecture_id:
                            body.location.prefecture_id,

                        name:
                            body.location.name?.trim() ||
                            null,

                        address_line_1:
                            body.location.address_line_1.trim(),

                        address_line_2:
                            body.location.address_line_2?.trim() ||
                            null,

                        postal_code:
                            body.location.postal_code.trim(),

                        city:
                            body.location.city.trim(),

                        country:
                            body.location.country.trim(),

                        latitude:
                            body.location.latitude ??
                            null,

                        longitude:
                            body.location.longitude ??
                            null,

                        notes:
                            body.location.notes?.trim() ||
                            null
                    }
                }
            );

        const mission =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        reply.code(201).send({
            success: true,
            mission
        });
    }

    // ============================================================
    // MODIFICATION
    // ============================================================

    public async update(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const {
            missionId
        } = request.params as {
            missionId: string
        };

        const existing =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        if (!existing) {
            throw new NotFoundError(
                'Mission introuvable.'
            );
        }

        const body =
            UpdateMissionSchema.parse(
                request.body
            );

        if (body.client_id) {

            if (
                !(await this.repository.clientBelongsToCompany(
                    payload.company_id,
                    body.client_id
                ))
            ) {
                throw new AuthorizationError(
                    'Client invalide.'
                );
            }
        }

        if (body.pilot_id) {

            if (
                !(await this.repository.pilotBelongsToCompany(
                    payload.company_id,
                    body.pilot_id
                ))
            ) {
                throw new AuthorizationError(
                    'Pilote actif invalide.'
                );
            }
        }

        if (body.category_id) {

            if (
                !(await this.repository.categoryExists(
                    body.category_id
                ))
            ) {
                throw new NotFoundError(
                    'Catégorie invalide.'
                );
            }
        }

        if (body.mission_status_id) {

            if (
                !(await this.repository.statusExists(
                    body.mission_status_id
                ))
            ) {
                throw new NotFoundError(
                    'Statut invalide.'
                );
            }
        }

        if (
            body.location?.drone_id &&
            !(await this.repository.droneBelongsToCompany(
                payload.company_id,
                body.location.drone_id
            ))
        ) {
            throw new AuthorizationError(
                'Drone actif invalide.'
            );
        }

        if (
            body.location?.prefecture_id &&
            !(await this.repository.prefectureExists(
                body.location.prefecture_id
            ))
        ) {
            throw new NotFoundError(
                'Préfecture invalide.'
            );
        }

        const missionData: Record<string, unknown> = {};

        if (body.client_id !== undefined)
            missionData.client_id =
                body.client_id;

        if (body.pilot_id !== undefined)
            missionData.pilot_id =
                body.pilot_id;

        if (body.category_id !== undefined)
            missionData.category_id =
                body.category_id;

        if (body.mission_status_id !== undefined)
            missionData.mission_status_id =
                body.mission_status_id;

        if (body.reference !== undefined)
            missionData.reference =
                body.reference?.trim() || null;

        if (body.title !== undefined)
            missionData.title =
                body.title.trim();

        if (body.description !== undefined)
            missionData.description =
                body.description?.trim() || null;

        if (body.planned_at !== undefined)
            missionData.planned_at =
                body.planned_at
                    ? new Date(body.planned_at)
                    : null;

        if (body.notes !== undefined)
            missionData.notes =
                body.notes?.trim() || null;

        let locationData:
            Record<string, unknown> | undefined;

        if (body.location) {

            locationData = {};

            const location = body.location;

            if (location.site_id !== undefined)
                locationData.site_id =
                    location.site_id ?? null;

            if (location.drone_id !== undefined)
                locationData.drone_id =
                    location.drone_id;

            if (location.prefecture_id !== undefined)
                locationData.prefecture_id =
                    location.prefecture_id;

            if (location.name !== undefined)
                locationData.name =
                    location.name?.trim() || null;

            if (location.address_line_1 !== undefined)
                locationData.address_line_1 =
                    location.address_line_1.trim();

            if (location.address_line_2 !== undefined)
                locationData.address_line_2 =
                    location.address_line_2?.trim() || null;

            if (location.postal_code !== undefined)
                locationData.postal_code =
                    location.postal_code.trim();

            if (location.city !== undefined)
                locationData.city =
                    location.city.trim();

            if (location.country !== undefined)
                locationData.country =
                    location.country.trim();

            if (location.latitude !== undefined)
                locationData.latitude =
                    location.latitude ?? null;

            if (location.longitude !== undefined)
                locationData.longitude =
                    location.longitude ?? null;

            if (location.notes !== undefined)
                locationData.notes =
                    location.notes?.trim() || null;
        }

        await this.repository.update(
            payload.company_id,
            missionId,
            missionData,
            locationData
        );

        const mission =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        reply.send({
            success: true,
            mission
        });
    }

    // ============================================================
    // STATUT
    // ============================================================

    public async status(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const {
            missionId
        } = request.params as {
            missionId: string
        };

        const body =
            UpdateMissionStatusSchema.parse(
                request.body
            );

        const existing =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        if (!existing) {
            throw new NotFoundError(
                'Mission introuvable.'
            );
        }

        if (
            !(await this.repository.statusExists(
                body.mission_status_id
            ))
        ) {
            throw new NotFoundError(
                'Statut invalide.'
            );
        }

        await this.repository.setStatus(
            payload.company_id,
            missionId,
            body.mission_status_id
        );

        reply.send({
            success: true
        });
    }

    // ============================================================
    // ARCHIVAGE
    // ============================================================

    public async archive(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const {
            missionId
        } = request.params as {
            missionId: string
        };

        const existing =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        if (!existing) {
            throw new NotFoundError(
                'Mission introuvable.'
            );
        }

        await this.repository.archive(
            payload.company_id,
            missionId,
            !existing.is_archived
        );

        reply.send({
            success: true,
            is_archived:
                !existing.is_archived
        });
    }

    // ============================================================
    // SUPPRESSION LOGIQUE
    // ============================================================

    public async delete(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {

        const payload =
            await request.jwtVerify<AuthPayload>();

        this.checkManagement(payload.role);

        const {
            missionId
        } = request.params as {
            missionId: string
        };

        const existing =
            await this.repository.findById(
                payload.company_id,
                missionId
            );

        if (!existing) {
            throw new NotFoundError(
                'Mission introuvable.'
            );
        }

        await this.repository.delete(
            payload.company_id,
            missionId
        );

        reply.send({
            success: true
        });
    }

}
