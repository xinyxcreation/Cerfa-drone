import { RowDataPacket } from 'mysql2/promise';
import { BaseRepository } from './BaseRepository.js';

export class MissionCategoryRepository extends BaseRepository {

    public async findAll(
        companyId: string
    ): Promise<RowDataPacket[]> {
        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    mc.id,
                    mc.code,
                    mc.label,
                    mc.description,
                    mc.sort_order,
                    mc.is_active,
                    mc.created_at,
                    mc.updated_at,
                    ccdd.drone_id AS default_drone_id,
                    CASE
                        WHEN d.nickname IS NOT NULL
                             AND d.nickname <> ''
                        THEN CONCAT(
                            d.nickname,
                            ' — ',
                            d.manufacturer,
                            ' ',
                            d.model
                        )
                        ELSE CONCAT(
                            d.manufacturer,
                            ' ',
                            d.model
                        )
                    END AS default_drone_name
                FROM mission_categories mc
                LEFT JOIN company_category_drone_defaults ccdd
                    ON ccdd.category_id = mc.id
                   AND ccdd.company_id = ?
                LEFT JOIN drones d
                    ON d.id = ccdd.drone_id
                   AND d.company_id = ?
                   AND d.deleted_at IS NULL
                   AND d.is_active = TRUE
                WHERE mc.deleted_at IS NULL
                ORDER BY mc.sort_order, mc.label
                `,
                [companyId, companyId]
            );

        return rows;
    }

    public async findById(
        id: string,
        companyId?: string
    ): Promise<RowDataPacket | null> {
        let query: string;
        let params: string[];

        if (companyId) {
            query = `
                SELECT
                    mc.id,
                    mc.code,
                    mc.label,
                    mc.description,
                    mc.sort_order,
                    mc.is_active,
                    mc.created_at,
                    mc.updated_at,
                    ccdd.drone_id AS default_drone_id,
                    CASE
                        WHEN d.nickname IS NOT NULL
                             AND d.nickname <> ''
                        THEN CONCAT(
                            d.nickname,
                            ' — ',
                            d.manufacturer,
                            ' ',
                            d.model
                        )
                        ELSE CONCAT(
                            d.manufacturer,
                            ' ',
                            d.model
                        )
                    END AS default_drone_name
                FROM mission_categories mc
                LEFT JOIN company_category_drone_defaults ccdd
                    ON ccdd.category_id = mc.id
                   AND ccdd.company_id = ?
                LEFT JOIN drones d
                    ON d.id = ccdd.drone_id
                   AND d.company_id = ?
                   AND d.deleted_at IS NULL
                WHERE mc.id = ?
                  AND mc.deleted_at IS NULL
                LIMIT 1
            `;

            params = [companyId, companyId, id];
        } else {
            query = `
                SELECT
                    id,
                    code,
                    label,
                    description,
                    sort_order,
                    is_active,
                    created_at,
                    updated_at
                FROM mission_categories
                WHERE id = ?
                  AND deleted_at IS NULL
                LIMIT 1
            `;

            params = [id];
        }

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                query,
                params
            );

        return rows[0] ?? null;
    }

    public async create(data: {
        code: string;
        label: string;
        description?: string | null;
        sort_order?: number;
    }): Promise<string> {
        return this.baseInsert(
            'mission_categories',
            {
                code: data.code,
                label: data.label,
                description: data.description ?? null,
                sort_order: data.sort_order ?? 0,
                is_active: true,
            }
        );
    }

    public async update(
        id: string,
        data: Record<string, unknown>
    ): Promise<void> {
        await this.baseUpdate(
            'mission_categories',
            id,
            data
        );
    }

    public async droneBelongsToCompany(
        droneId: string,
        companyId: string
    ): Promise<boolean> {
        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM drones
                WHERE id = ?
                  AND company_id = ?
                  AND deleted_at IS NULL
                  AND is_active = TRUE
                LIMIT 1
                `,
                [droneId, companyId]
            );

        return rows.length > 0;
    }

    public async setDefaultDrone(
        companyId: string,
        categoryId: string,
        droneId: string | null
    ): Promise<void> {
        if (droneId === null) {
            await this.db.execute(
                `
                DELETE FROM company_category_drone_defaults
                WHERE company_id = ?
                  AND category_id = ?
                `,
                [companyId, categoryId]
            );

            return;
        }

        await this.db.execute(
            `
            INSERT INTO company_category_drone_defaults
                (
                    company_id,
                    category_id,
                    drone_id,
                    created_at,
                    updated_at
                )
            VALUES (
                ?,
                ?,
                ?,
                UTC_TIMESTAMP(6),
                UTC_TIMESTAMP(6)
            )
            ON DUPLICATE KEY UPDATE
                drone_id = VALUES(drone_id),
                updated_at = UTC_TIMESTAMP(6)
            `,
            [companyId, categoryId, droneId]
        );
    }

    public async deactivate(id: string): Promise<void> {
        await this.baseUpdate(
            'mission_categories',
            id,
            { is_active: false }
        );
    }

    public async activate(id: string): Promise<void> {
        await this.baseUpdate(
            'mission_categories',
            id,
            { is_active: true }
        );
    }

    public async delete(id: string): Promise<void> {
        await this.baseDelete(
            'mission_categories',
            id
        );
    }
}
