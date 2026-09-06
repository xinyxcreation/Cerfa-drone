import { RowDataPacket } from 'mysql2/promise';
import { BaseRepository } from './BaseRepository.js';

export class SiteRepository extends BaseRepository {

    public async findAll(
        companyId: string
    ): Promise<RowDataPacket[]> {
        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    s.id,
                    s.site_reference,
                    s.name,
                    s.description,
                    s.client_id,
                    c.name AS client_name,
                    s.category_id,
                    mc.label AS category_label,
                    s.default_drone_id,
                    d.nickname AS default_drone_name,
                    s.default_pilot_id,
                    u.email AS default_pilot_email,
                    s.address_line_1,
                    s.address_line_2,
                    s.postal_code,
                    s.city,
                    s.country,
                    s.latitude,
                    s.longitude,
                    s.prefecture_id,
                    p.prefecture_name,
                    s.is_favorite,
                    s.is_active,
                    s.notes
                FROM sites s
                LEFT JOIN clients c
                    ON c.id = s.client_id
                   AND c.deleted_at IS NULL
                LEFT JOIN mission_categories mc
                    ON mc.id = s.category_id
                   AND mc.deleted_at IS NULL
                LEFT JOIN drones d
                    ON d.id = s.default_drone_id
                   AND d.deleted_at IS NULL
                LEFT JOIN company_users cu
                    ON cu.user_id = s.default_pilot_id
                   AND cu.company_id = s.company_id
                   AND cu.deleted_at IS NULL
                LEFT JOIN users u
                    ON u.id = cu.user_id
                   AND u.deleted_at IS NULL
                LEFT JOIN prefectures p
                    ON p.id = s.prefecture_id
                WHERE s.company_id = ?
                  AND s.deleted_at IS NULL
                ORDER BY s.is_favorite DESC, s.name
                `,
                [companyId]
            );

        return rows;
    }

    public async findById(
        companyId: string,
        id: string
    ): Promise<RowDataPacket | null> {
        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT *
                FROM sites
                WHERE company_id = ?
                  AND id = ?
                  AND deleted_at IS NULL
                LIMIT 1
                `,
                [companyId, id]
            );

        return rows[0] ?? null;
    }

    public async create(
        companyId: string,
        data: Record<string, unknown>
    ): Promise<string> {
        return this.baseInsert(
            'sites',
            {
                company_id: companyId,
                ...data,
                is_active: true,
            }
        );
    }

    public async update(
        id: string,
        data: Record<string, unknown>
    ): Promise<void> {
        await this.baseUpdate(
            'sites',
            id,
            data
        );
    }
}
