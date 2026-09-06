import { RowDataPacket } from 'mysql2/promise';

import { BaseRepository } from './BaseRepository.js';

export interface PilotCertification extends RowDataPacket {
    id: string;
    code: string;
    label: string;
    description: string | null;
    obtained_at: Date;
    expires_at: Date | null;
    reminder_days: number | null;
    is_valid: boolean;
    notes: string | null;
}

export interface CertificationType extends RowDataPacket {
    id: string;
    code: string;
    label: string;
    description: string | null;
    default_validity_days: number | null;
    default_reminder_days: number;
}

export class CertificationRepository extends BaseRepository {

    public async findTypes(): Promise<CertificationType[]> {

        const [rows] =
            await this.db.query<CertificationType[]>(
                `
                SELECT
                    id,
                    code,
                    label,
                    description,
                    default_validity_days,
                    default_reminder_days
                FROM certification_types
                WHERE is_active = TRUE
                AND deleted_at IS NULL
                ORDER BY sort_order, code
                `
            );

        return rows;
    }

    public async findByPilotId(
        pilotId: string
    ): Promise<PilotCertification[]> {

        const [rows] =
            await this.db.query<PilotCertification[]>(
                `
                SELECT
                    c.id,
                    ct.code,
                    ct.label,
                    ct.description,
                    c.obtained_at,
                    c.expires_at,
                    c.reminder_days,
                    c.is_valid,
                    c.notes

                FROM certifications c

                INNER JOIN certification_types ct
                    ON ct.id = c.certification_type_id

                INNER JOIN entity_types et
                    ON et.id = c.entity_type_id

                WHERE et.code = 'pilot'
                AND c.entity_id = ?

                AND c.deleted_at IS NULL
                AND ct.deleted_at IS NULL
                AND ct.is_active = TRUE

                ORDER BY
                    ct.sort_order,
                    ct.code
                `,
                [pilotId]
            );

        return rows;
    }

    public async findTypeByCode(
        code: string
    ): Promise<CertificationType | null> {

        const [rows] =
            await this.db.query<CertificationType[]>(
                `
                SELECT
                    id,
                    code,
                    label,
                    description,
                    default_validity_days,
                    default_reminder_days
                FROM certification_types
                WHERE code = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [code]
            );

        return rows.length > 0 ? rows[0] : null;
    }

    public async create(
        pilotId: string,
        certificationTypeId: string,
        obtainedAt: Date,
        expiresAt: Date | null,
        reminderDays: number | null,
        notes: string | null
    ): Promise<string> {

        const entityType =
            await this.findEntityTypeId('pilot');

        if (!entityType) {
            throw new Error(
                'Type d’entité pilote introuvable.'
            );
        }

        return this.baseInsert(
            'certifications',
            {
                entity_type_id: entityType,
                entity_id: pilotId,
                certification_type_id: certificationTypeId,
                obtained_at: obtainedAt,
                expires_at: expiresAt,
                reminder_days: reminderDays,
                is_valid: true,
                notes
            }
        );
    }

    public async update(
        id: string,
        data: {
            certification_type_id?: string;
            obtained_at?: Date;
            expires_at?: Date | null;
            reference?: string | null;
            reminder_days?: number | null;
            is_valid?: boolean;
            notes?: string | null;
        }
    ): Promise<void> {

        await this.baseUpdate(
            'certifications',
            id,
            data
        );
    }

    public async delete(
        id: string
    ): Promise<void> {

        await this.baseDelete(
            'certifications',
            id
        );
    }

    private async findEntityTypeId(
        code: string
    ): Promise<string | null> {

        const [rows] =
            await this.db.query<RowDataPacket[]>(
                `
                SELECT id
                FROM entity_types
                WHERE code = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
                [code]
            );

        return rows.length > 0
            ? String(rows[0].id)
            : null;
    }
}
