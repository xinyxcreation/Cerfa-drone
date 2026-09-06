import { RowDataPacket } from 'mysql2/promise';

import { BaseRepository } from './BaseRepository.js';

export interface Drone extends RowDataPacket {
    id: string;
    company_id: string;
    nickname: string | null;
    manufacturer: string;
    model: string;
    serial_number: string;
    alphatango_aircraft_number: string;
    drone_class: string | null;
    weight_g: number | null;
    notes: string | null;
    is_active: boolean;
    created_at: Date;
    updated_at: Date;
    deleted_at: Date | null;
    sync_cursor: number;
}

export class DroneRepository extends BaseRepository {

    private readonly table = 'drones';

    public async findByCompanyId(
        companyId: string
    ): Promise<Drone[]> {

        const [rows] =
            await this.db.query<Drone[]>(
                `
                SELECT
                    id,
                    company_id,
                    nickname,
                    manufacturer,
                    model,
                    serial_number,
                    alphatango_aircraft_number,
                    drone_class,
                    weight_g,
                    notes,
                    is_active,
                    created_at,
                    updated_at,
                    deleted_at,
                    sync_cursor
                FROM drones
                WHERE company_id = ?
                AND deleted_at IS NULL
                ORDER BY
                    manufacturer,
                    model,
                    nickname,
                    serial_number
                `,
                [companyId]
            );

        return rows;
    }

    public async findByCompanyAndId(
        companyId: string,
        id: string
    ): Promise<Drone | null> {

        const [rows] =
            await this.db.query<Drone[]>(
                `
                SELECT
                    id,
                    company_id,
                    nickname,
                    manufacturer,
                    model,
                    serial_number,
                    alphatango_aircraft_number,
                    drone_class,
                    weight_g,
                    notes,
                    is_active,
                    created_at,
                    updated_at,
                    deleted_at,
                    sync_cursor
                FROM drones
                WHERE company_id = ?
                AND id = ?
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [companyId, id]
            );

        return rows.length > 0
            ? rows[0]
            : null;
    }

    public async findDeletedByCompanyAndSerialNumber(
        companyId: string,
        serialNumber: string
    ): Promise<Drone | null> {

        const [rows] =
            await this.db.query<Drone[]>(
                `
                SELECT
                    id,
                    company_id,
                    nickname,
                    manufacturer,
                    model,
                    serial_number,
                    alphatango_aircraft_number,
                    drone_class,
                    weight_g,
                    notes,
                    is_active,
                    created_at,
                    updated_at,
                    deleted_at,
                    sync_cursor
                FROM drones
                WHERE company_id = ?
                  AND serial_number = ?
                  AND deleted_at IS NOT NULL
                ORDER BY deleted_at DESC
                LIMIT 1
                `,
                [companyId, serialNumber]
            );

        return rows.length > 0
            ? rows[0]
            : null;
    }

    public async findDeletedByCompanyAndAlphaTango(
        companyId: string,
        alphaTangoAircraftNumber: string
    ): Promise<Drone | null> {

        const [rows] =
            await this.db.query<Drone[]>(
                `
                SELECT
                    id,
                    company_id,
                    nickname,
                    manufacturer,
                    model,
                    serial_number,
                    alphatango_aircraft_number,
                    drone_class,
                    weight_g,
                    notes,
                    is_active,
                    created_at,
                    updated_at,
                    deleted_at,
                    sync_cursor
                FROM drones
                WHERE company_id = ?
                  AND alphatango_aircraft_number = ?
                  AND deleted_at IS NOT NULL
                ORDER BY deleted_at DESC
                LIMIT 1
                `,
                [companyId, alphaTangoAircraftNumber]
            );

        return rows.length > 0
            ? rows[0]
            : null;
    }

    public async create(
        companyId: string,
        data: {
            nickname: string | null;
            manufacturer: string;
            model: string;
            serial_number: string;
            alphatango_aircraft_number: string;
            drone_class: string | null;
            weight_g: number | null;
            notes: string | null;
        }
    ): Promise<string> {

        return this.baseInsert(
            this.table,
            {
                company_id: companyId,
                nickname: data.nickname,
                manufacturer: data.manufacturer,
                model: data.model,
                serial_number: data.serial_number,
                alphatango_aircraft_number:
                    data.alphatango_aircraft_number,
                drone_class: data.drone_class,
                weight_g: data.weight_g,
                notes: data.notes,
                is_active: true
            }
        );
    }

    public async update(
        companyId: string,
        id: string,
        data: {
            nickname?: string | null;
            manufacturer?: string;
            model?: string;
            serial_number?: string;
            alphatango_aircraft_number?: string;
            drone_class?: string | null;
            weight_g?: number | null;
            notes?: string | null;
        }
    ): Promise<void> {

        const columns = Object.keys(data);

        if (columns.length === 0) {
            return;
        }

        const assignments = columns
            .map(column => `${column} = ?`)
            .join(', ');

        await this.db.query(
            `
            UPDATE drones
            SET
                ${assignments},
                updated_at = UTC_TIMESTAMP(6)
            WHERE company_id = ?
            AND id = ?
            AND deleted_at IS NULL
            `,
            [
                ...Object.values(data),
                companyId,
                id
            ]
        );
    }

    public async activate(
        companyId: string,
        id: string
    ): Promise<void> {

        await this.db.query(
            `
            UPDATE drones
            SET
                is_active = TRUE,
                updated_at = UTC_TIMESTAMP(6)
            WHERE company_id = ?
            AND id = ?
            AND deleted_at IS NULL
            `,
            [
                companyId,
                id
            ]
        );
    }

    public async deactivate(
        companyId: string,
        id: string
    ): Promise<void> {

        await this.db.query(
            `
            UPDATE drones
            SET
                is_active = FALSE,
                updated_at = UTC_TIMESTAMP(6)
            WHERE company_id = ?
            AND id = ?
            AND deleted_at IS NULL
            `,
            [companyId, id]
        );
    }
    public async delete(
        companyId: string,
        id: string
    ): Promise<void> {

        await this.db.query(
            `
            UPDATE drones
            SET
                deleted_at = UTC_TIMESTAMP(6),
                updated_at = UTC_TIMESTAMP(6),
                is_active = FALSE
            WHERE company_id = ?
            AND id = ?
            AND deleted_at IS NULL
            `,
            [
                companyId,
                id
            ]
        );
    }


}
