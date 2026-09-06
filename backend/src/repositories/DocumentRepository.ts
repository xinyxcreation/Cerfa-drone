import { RowDataPacket } from "mysql2/promise";

import { BaseRepository } from "./BaseRepository.js";

export interface DocumentType extends RowDataPacket {
  id: string;
  entity_type_id: string;

  code: string;
  label: string;
  description: string | null;

  default_validity_days: number | null;
  default_reminder_days: number;

  is_required: boolean;
  is_active: boolean;

  sort_order: number;
}

export interface DocumentValidity extends RowDataPacket {
  id: string;

  entity_type_id: string;
  entity_id: string;

  document_type_id: string;

  reference: string | null;

  issued_at: Date | null;
  expires_at: Date;

  reminder_days: number | null;

  file_original_name: string | null;
  file_stored_name: string | null;
  file_storage_path: string | null;
  file_mime_type: string | null;
  file_size: number | null;

  is_valid: boolean;

  notes: string | null;

  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;

  sync_cursor: number;
}

export interface DocumentWithType extends DocumentValidity {
  document_code: string;
  document_label: string;
  document_description: string | null;

  default_validity_days: number | null;
  default_reminder_days: number;

  is_required: boolean;
}

export class DocumentRepository extends BaseRepository {
  private readonly table = "documents_validity";

  public async findTypes(): Promise<DocumentType[]> {
    const [rows] = await this.db.query<DocumentType[]>(
      `
                SELECT
                    id,
                    entity_type_id,
                    code,
                    label,
                    description,
                    default_validity_days,
                    default_reminder_days,
                    is_required,
                    is_active,
                    sort_order

                FROM document_types

                WHERE is_active = TRUE
                AND deleted_at IS NULL

                ORDER BY
                    sort_order,
                    code
                `,
    );

    return rows;
  }

  public async findById(id: string): Promise<DocumentWithType | null> {
    const [rows] = await this.db.query<DocumentWithType[]>(
      `
                SELECT
                    d.*,

                    dt.code AS document_code,
                    dt.label AS document_label,
                    dt.description AS document_description,

                    dt.default_validity_days,
                    dt.default_reminder_days,

                    dt.is_required

                FROM documents_validity d

                INNER JOIN document_types dt
                    ON dt.id = d.document_type_id

                WHERE d.id = ?
                AND d.deleted_at IS NULL
                AND dt.deleted_at IS NULL

                LIMIT 1
                `,
      [id],
    );

    return rows.length > 0 ? rows[0] : null;
  }

  public async findByEntity(
    entityTypeId: string,
    entityId: string,
  ): Promise<DocumentWithType[]> {
    const [rows] = await this.db.query<DocumentWithType[]>(
      `
                SELECT
                    d.*,

                    dt.code AS document_code,
                    dt.label AS document_label,
                    dt.description AS document_description,

                    dt.default_validity_days,
                    dt.default_reminder_days,

                    dt.is_required

                FROM documents_validity d

                INNER JOIN document_types dt
                    ON dt.id = d.document_type_id

                WHERE d.entity_type_id = ?
                AND d.entity_id = ?

                AND d.deleted_at IS NULL
                AND dt.deleted_at IS NULL
                AND dt.is_active = TRUE

                ORDER BY
                    dt.sort_order,
                    dt.label,
                    d.expires_at
                `,
      [entityTypeId, entityId],
    );

    return rows;
  }

  public async findByCompanyId(companyId: string): Promise<DocumentWithType[]> {
    const companyTypeId = await this.findEntityTypeId("company");
    const pilotTypeId = await this.findEntityTypeId("pilot");
    const droneTypeId = await this.findEntityTypeId("drone");

    if (!companyTypeId && !pilotTypeId && !droneTypeId) {
      return [];
    }

    const conditions: string[] = [];
    const params: unknown[] = [];

    if (companyTypeId) {
      conditions.push(`(d.entity_type_id = ? AND d.entity_id = ?)`);
      params.push(companyTypeId, companyId);
    }

    if (pilotTypeId) {
      conditions.push(
        `(d.entity_type_id = ? AND d.entity_id IN (
                    SELECT cu.user_id
                    FROM company_users cu
                    WHERE cu.company_id = ?
                    AND cu.is_active = TRUE
                    AND cu.deleted_at IS NULL
                ))`,
      );
      params.push(pilotTypeId, companyId);
    }

    if (droneTypeId) {
      conditions.push(
        `(d.entity_type_id = ? AND d.entity_id IN (
                    SELECT dr.id
                    FROM drones dr
                    WHERE dr.company_id = ?
                    AND dr.deleted_at IS NULL
                ))`,
      );
      params.push(droneTypeId, companyId);
    }

    const [rows] = await this.db.query<DocumentWithType[]>(
      `
                SELECT
                    d.*,

                    dt.code AS document_code,
                    dt.label AS document_label,
                    dt.description AS document_description,

                    dt.default_validity_days,
                    dt.default_reminder_days,

                    dt.is_required

                FROM documents_validity d

                INNER JOIN document_types dt
                    ON dt.id = d.document_type_id

                WHERE d.deleted_at IS NULL
                AND dt.deleted_at IS NULL
                AND dt.is_active = TRUE

                AND (${conditions.join(" OR ")})

                ORDER BY
                    d.expires_at,
                    dt.sort_order,
                    dt.label
                `,
      params,
    );

    return rows;
  }

  public async create(
    entityTypeId: string,
    entityId: string,
    documentTypeId: string,
    reference: string | null,
    issuedAt: Date | null,
    expiresAt: Date,
    reminderDays: number | null,
    notes: string | null,
    fileOriginalName: string | null = null,
    fileStoredName: string | null = null,
    fileStoragePath: string | null = null,
    fileMimeType: string | null = null,
    fileSize: number | null = null,
  ): Promise<string> {
    return this.baseInsert(this.table, {
      entity_type_id: entityTypeId,
      entity_id: entityId,
      document_type_id: documentTypeId,

      reference,

      issued_at: issuedAt,
      expires_at: expiresAt,

      reminder_days: reminderDays,

      file_original_name: fileOriginalName,
      file_stored_name: fileStoredName,
      file_storage_path: fileStoragePath,
      file_mime_type: fileMimeType,
      file_size: fileSize,

      is_valid: true,

      notes,
    });
  }

  public async update(
    id: string,
    data: {
      document_type_id?: string;
      reference?: string | null;
      issued_at?: Date | null;
      expires_at?: Date;
      reminder_days?: number | null;
      file_original_name?: string | null;
      file_stored_name?: string | null;
      file_storage_path?: string | null;
      file_mime_type?: string | null;
      file_size?: number | null;
      is_valid?: boolean;
      notes?: string | null;
    },
  ): Promise<void> {
    await this.baseUpdate(this.table, id, data);
  }

  public async delete(id: string): Promise<void> {
    await this.baseDelete(this.table, id);
  }

  private async findEntityTypeId(code: string): Promise<string | null> {
    const [rows] = await this.db.query<RowDataPacket[]>(
      `
                SELECT id
                FROM entity_types
                WHERE code = ?
                AND is_active = TRUE
                AND deleted_at IS NULL
                LIMIT 1
                `,
      [code],
    );

    return rows.length > 0 ? String(rows[0].id) : null;
  }
}
