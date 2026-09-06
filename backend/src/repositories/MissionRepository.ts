import {
    Pool,
    RowDataPacket,
    ResultSetHeader
} from 'mysql2/promise';

import { getDatabase } from '../database/core/DatabaseConnection.js';
import { v7 as uuidv7 } from 'uuid';

export interface MissionRow extends RowDataPacket {

    id: string;
    company_id: string;

    client_id: string;
    client_name: string;

    pilot_id: string;
    pilot_firstname: string;
    pilot_lastname: string;
    pilot_email: string;

    category_id: string;
    category_code: string;
    category_label: string;

    mission_status_id: string;
    status_code: string;
    status_label: string;

    reference: string | null;

    title: string;
    description: string | null;

    planned_at: Date | null;
    started_at: Date | null;
    completed_at: Date | null;

    is_archived: boolean;

    notes: string | null;

    created_at: Date;
    updated_at: Date;
    deleted_at: Date | null;

}

export interface MissionLocationRow extends RowDataPacket {

    id: string;
    mission_id: string;

    site_id: string | null;
    drone_id: string;
    drone_nickname: string | null;
    drone_manufacturer: string;
    drone_model: string;
    drone_serial_number: string;

    prefecture_id: string;
    prefecture_code: string | null;
    prefecture_name: string | null;

    name: string | null;

    address_line_1: string;
    address_line_2: string | null;

    postal_code: string;
    city: string;
    country: string;

    latitude: number | null;
    longitude: number | null;

    intervention_order: number;
    is_completed: boolean;

    notes: string | null;

}

export class MissionRepository {

    private readonly db: Pool =
        getDatabase();

    // ============================================================
    // MISSIONS
    // ============================================================

    public async findAll(
        companyId: string
    ): Promise<MissionRow[]> {

        const [rows] =
            await this.db.query<MissionRow[]>(
                `
                SELECT
                    m.*,

                    c.name AS client_name,

                    u.firstname AS pilot_firstname,
                    u.lastname AS pilot_lastname,
                    u.email AS pilot_email,

                    mc.code AS category_code,
                    mc.label AS category_label,

                    ms.code AS status_code,
                    ms.label AS status_label

                FROM missions m

                INNER JOIN clients c
                    ON c.id = m.client_id

                INNER JOIN users u
                    ON u.id = m.pilot_id

                INNER JOIN mission_categories mc
                    ON mc.id = m.category_id

                INNER JOIN mission_statuses ms
                    ON ms.id = m.mission_status_id

                WHERE m.company_id = ?
                AND m.deleted_at IS NULL

                ORDER BY
                    m.planned_at IS NULL,
                    m.planned_at DESC,
                    m.created_at DESC
                `,
                [companyId]
            );

        return rows;
    }

    public async findById(
        companyId: string,
        missionId: string
    ): Promise<MissionRow | null> {

        const [rows] =
            await this.db.query<MissionRow[]>(
                `
                SELECT
                    m.*,

                    c.name AS client_name,

                    u.firstname AS pilot_firstname,
                    u.lastname AS pilot_lastname,
                    u.email AS pilot_email,

                    mc.code AS category_code,
                    mc.label AS category_label,

                    ms.code AS status_code,
                    ms.label AS status_label

                FROM missions m

                INNER JOIN clients c
                    ON c.id = m.client_id

                INNER JOIN users u
                    ON u.id = m.pilot_id

                INNER JOIN mission_categories mc
                    ON mc.id = m.category_id

                INNER JOIN mission_statuses ms
                    ON ms.id = m.mission_status_id

                WHERE m.id = ?
                AND m.company_id = ?
                AND m.deleted_at IS NULL

                LIMIT 1
                `,
                [missionId, companyId]
            );

        return rows[0] ?? null;
    }

    public async findLocation(
        missionId: string
    ): Promise<MissionLocationRow | null> {

        const [rows] =
            await this.db.query<MissionLocationRow[]>(
                `
                SELECT
                    ml.*,

                    d.nickname AS drone_nickname,
                    d.manufacturer AS drone_manufacturer,
                    d.model AS drone_model,
                    d.serial_number AS drone_serial_number,

                    p.code AS prefecture_code,
                    p.name AS prefecture_name

                FROM mission_locations ml

                INNER JOIN drones d
                    ON d.id = ml.drone_id

                INNER JOIN prefectures p
                    ON p.id = ml.prefecture_id

                WHERE ml.mission_id = ?
                AND ml.deleted_at IS NULL

                ORDER BY ml.intervention_order ASC

                LIMIT 1
                `,
                [missionId]
            );

        return rows[0] ?? null;
    }

    // ============================================================
    // REFERENTIELS
    // ============================================================

    public async findClients(
        companyId: string
    ): Promise<RowDataPacket[]> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    id,
                    name
                FROM clients
                WHERE company_id = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                ORDER BY name
                `,
                [companyId]
            );

        return rows;
    }

    public async findPilots(
        companyId: string
    ): Promise<RowDataPacket[]> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    u.id,
                    u.firstname,
                    u.lastname,
                    u.email

                FROM company_users cu

                INNER JOIN users u
                    ON u.id = cu.user_id

                WHERE cu.company_id = ?
                AND cu.is_pilot = TRUE
                AND cu.is_active = TRUE
                AND cu.deleted_at IS NULL
                AND u.is_active = TRUE
                AND u.deleted_at IS NULL

                ORDER BY
                    u.lastname,
                    u.firstname,
                    u.email
                `,
                [companyId]
            );

        return rows;
    }

    public async findDrones(
        companyId: string
    ): Promise<RowDataPacket[]> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    id,
                    nickname,
                    manufacturer,
                    model,
                    serial_number

                FROM drones

                WHERE company_id = ?
                AND is_active = TRUE
                AND deleted_at IS NULL

                ORDER BY
                    nickname,
                    manufacturer,
                    model
                `,
                [companyId]
            );

        return rows;
    }

    public async findCategories(): Promise<RowDataPacket[]> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    id,
                    code,
                    label,
                    description

                FROM mission_categories

                WHERE is_active = TRUE
                AND deleted_at IS NULL

                ORDER BY
                    sort_order,
                    label
                `
            );

        return rows;
    }

    public async findStatuses(): Promise<RowDataPacket[]> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    id,
                    code,
                    label,
                    description

                FROM mission_statuses

                WHERE is_active = TRUE
                AND deleted_at IS NULL

                ORDER BY
                    sort_order,
                    label
                `
            );

        return rows;
    }

    public async findPrefectures(): Promise<RowDataPacket[]> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT
                    id,
                    code,
                    prefecture_name

                FROM prefectures

                ORDER BY
                    prefecture_name
                `
            );

        return rows;
    }

    // ============================================================
    // VALIDATIONS
    // ============================================================

    public async clientBelongsToCompany(
        companyId: string,
        clientId: string
    ): Promise<boolean> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM clients
                WHERE id = ?
                AND company_id = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [clientId, companyId]
            );

        return rows.length > 0;
    }

    public async pilotBelongsToCompany(
        companyId: string,
        pilotId: string
    ): Promise<boolean> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT cu.user_id

                FROM company_users cu

                INNER JOIN users u
                    ON u.id = cu.user_id

                WHERE cu.company_id = ?
                AND cu.user_id = ?
                AND cu.is_pilot = TRUE
                AND cu.is_active = TRUE
                AND cu.deleted_at IS NULL
                AND u.is_active = TRUE
                AND u.deleted_at IS NULL

                LIMIT 1
                `,
                [companyId, pilotId]
            );

        return rows.length > 0;
    }

    public async droneBelongsToCompany(
        companyId: string,
        droneId: string
    ): Promise<boolean> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM drones
                WHERE id = ?
                AND company_id = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [droneId, companyId]
            );

        return rows.length > 0;
    }

    public async categoryExists(
        categoryId: string
    ): Promise<boolean> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM mission_categories
                WHERE id = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [categoryId]
            );

        return rows.length > 0;
    }

    public async statusExists(
        statusId: string
    ): Promise<boolean> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM mission_statuses
                WHERE id = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [statusId]
            );

        return rows.length > 0;
    }

    public async prefectureExists(
        prefectureId: string
    ): Promise<boolean> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM prefectures
                WHERE id = ?
                LIMIT 1
                `,
                [prefectureId]
            );

        return rows.length > 0;
    }

    // ============================================================
    // CREATION
    // ============================================================

    public async create(
        companyId: string,
        input: {
            client_id: string;
            pilot_id: string;
            category_id: string;
            mission_status_id: string;
            reference: string | null;
            title: string;
            description: string | null;
            planned_at: Date | null;
            notes: string | null;
            location: {
                site_id: string | null;
                drone_id: string;
                prefecture_id: string;
                name: string | null;
                address_line_1: string;
                address_line_2: string | null;
                postal_code: string;
                city: string;
                country: string;
                latitude: number | null;
                longitude: number | null;
                notes: string | null;
            };
        }
    ): Promise<string> {

        const connection =
            await this.db.getConnection();

        try {

            await connection.beginTransaction();

            const missionId = uuidv7();

            await connection.execute(
                `
                INSERT INTO missions
                (
                    id,
                    company_id,
                    client_id,
                    pilot_id,
                    category_id,
                    mission_status_id,
                    reference,
                    title,
                    description,
                    planned_at,
                    notes,
                    created_at,
                    updated_at,
                    sync_cursor
                )
                VALUES
                (
                    ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                    UTC_TIMESTAMP(6),
                    UTC_TIMESTAMP(6),
                    0
                )
                `,
                [
                    missionId,
                    companyId,
                    input.client_id,
                    input.pilot_id,
                    input.category_id,
                    input.mission_status_id,
                    input.reference,
                    input.title,
                    input.description,
                    input.planned_at,
                    input.notes
                ]
            );

            const locationId = uuidv7();

            await connection.execute(
                `
                INSERT INTO mission_locations
                (
                    id,
                    mission_id,
                    site_id,
                    drone_id,
                    prefecture_id,
                    name,
                    address_line_1,
                    address_line_2,
                    postal_code,
                    city,
                    country,
                    latitude,
                    longitude,
                    intervention_order,
                    is_completed,
                    notes,
                    created_at,
                    updated_at,
                    sync_cursor
                )
                VALUES
                (
                    ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                    ?, ?, 1, FALSE, ?,
                    UTC_TIMESTAMP(6),
                    UTC_TIMESTAMP(6),
                    0
                )
                `,
                [
                    locationId,
                    missionId,
                    input.location.site_id,
                    input.location.drone_id,
                    input.location.prefecture_id,
                    input.location.name,
                    input.location.address_line_1,
                    input.location.address_line_2,
                    input.location.postal_code,
                    input.location.city,
                    input.location.country,
                    input.location.latitude,
                    input.location.longitude,
                    input.location.notes
                ]
            );

            await connection.commit();

            return missionId;

        } catch (error) {

            await connection.rollback();

            throw error;

        } finally {

            connection.release();

        }
    }

    // ============================================================
    // MODIFICATION
    // ============================================================

    public async update(
        companyId: string,
        missionId: string,
        data: Record<string, unknown>,
        locationData?: Record<string, unknown>
    ): Promise<void> {

        const connection =
            await this.db.getConnection();

        try {

            await connection.beginTransaction();

            const missionColumns =
                Object.keys(data);

            if (missionColumns.length > 0) {

                const sql =
                    missionColumns
                    .map(column => `${column} = ?`)
                    .join(', ');

                await connection.query(
                    `
                    UPDATE missions
                    SET
                        ${sql},
                        updated_at = UTC_TIMESTAMP(6)
                    WHERE id = ?
                    AND company_id = ?
                    AND deleted_at IS NULL
                    `,
                    [
                        ...Object.values(data),
                        missionId,
                        companyId
                    ]
                );
            }

            if (locationData) {

                const locationColumns =
                    Object.keys(locationData);

                if (locationColumns.length > 0) {

                    const sql =
                        locationColumns
                        .map(column => `${column} = ?`)
                        .join(', ');

                    await connection.query(
                        `
                        UPDATE mission_locations
                        SET
                            ${sql},
                            updated_at = UTC_TIMESTAMP(6)
                        WHERE mission_id = ?
                        AND deleted_at IS NULL
                        `,
                        [
                            ...Object.values(locationData),
                            missionId
                        ]
                    );
                }
            }

            await connection.commit();

        } catch (error) {

            await connection.rollback();

            throw error;

        } finally {

            connection.release();

        }
    }

    public async setStatus(
        companyId: string,
        missionId: string,
        statusId: string
    ): Promise<void> {

        await this.db.execute(
            `
            UPDATE missions
            SET
                mission_status_id = ?,
                updated_at = UTC_TIMESTAMP(6)
            WHERE id = ?
            AND company_id = ?
            AND deleted_at IS NULL
            `,
            [
                statusId,
                missionId,
                companyId
            ]
        );
    }

    public async archive(
        companyId: string,
        missionId: string,
        archived: boolean
    ): Promise<void> {

        await this.db.execute(
            `
            UPDATE missions
            SET
                is_archived = ?,
                updated_at = UTC_TIMESTAMP(6)
            WHERE id = ?
            AND company_id = ?
            AND deleted_at IS NULL
            `,
            [
                archived,
                missionId,
                companyId
            ]
        );
    }

    public async delete(
        companyId: string,
        missionId: string
    ): Promise<void> {

        const connection =
            await this.db.getConnection();

        try {

            await connection.beginTransaction();

            await connection.execute(
                `
                UPDATE mission_locations
                SET
                    deleted_at = UTC_TIMESTAMP(6),
                    updated_at = UTC_TIMESTAMP(6)
                WHERE mission_id = ?
                AND deleted_at IS NULL
                `,
                [missionId]
            );

            await connection.query(
                `
                UPDATE missions
                SET
                    deleted_at = UTC_TIMESTAMP(6),
                    updated_at = UTC_TIMESTAMP(6)
                WHERE id = ?
                AND company_id = ?
                AND deleted_at IS NULL
                `,
                [
                    missionId,
                    companyId
                ]
            );

            await connection.commit();

        } catch (error) {

            await connection.rollback();

            throw error;

        } finally {

            connection.release();

        }
    }

}
