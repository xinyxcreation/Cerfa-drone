import { RowDataPacket } from 'mysql2/promise';
import { BaseRepository } from './BaseRepository.js';

export class ClientRepository extends BaseRepository {

    public async findAll(
        companyId: string
    ): Promise<RowDataPacket[]> {
        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    id,
                    customer_reference,
                    name,
                    contact_name,
                    email,
                    phone,
                    address_line_1,
                    address_line_2,
                    postal_code,
                    city,
                    country,
                    notes,
                    is_active
                FROM clients
                WHERE company_id = ?
                  AND deleted_at IS NULL
                ORDER BY name
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
                FROM clients
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
            'clients',
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
            'clients',
            id,
            data
        );
    }

    public async deactivate(id: string): Promise<void> {
        await this.baseUpdate(
            'clients',
            id,
            { is_active: false }
        );
    }

    public async activate(id: string): Promise<void> {
        await this.baseUpdate(
            'clients',
            id,
            { is_active: true }
        );
    }
}
