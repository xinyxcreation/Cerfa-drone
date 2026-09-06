import { AuthorizationError } from "../errors/AuthorizationError.js";
import { NotFoundError } from "../errors/NotFoundError.js";

import {
  DocumentRepository,
  DocumentType,
  DocumentWithType,
} from "../repositories/DocumentRepository.js";

export interface CreateDocumentInput {
  entityTypeId: string;
  entityId: string;
  documentTypeId: string;

  reference?: string | null;

  issuedAt?: Date | null;
  expiresAt: Date;

  reminderDays?: number | null;

  fileOriginalName?: string | null;
  fileStoredName?: string | null;
  fileStoragePath?: string | null;
  fileMimeType?: string | null;
  fileSize?: number | null;

  notes?: string | null;
}

export interface UpdateDocumentInput {
  documentTypeId?: string;

  reference?: string | null;

  issuedAt?: Date | null;
  expiresAt?: Date;

  reminderDays?: number | null;

  fileOriginalName?: string | null;
  fileStoredName?: string | null;
  fileStoragePath?: string | null;
  fileMimeType?: string | null;
  fileSize?: number | null;

  isValid?: boolean;

  notes?: string | null;
}

export class DocumentService {
  private readonly documents = new DocumentRepository();

  // ============================================================
  // TYPES DE DOCUMENTS
  // ============================================================

  public async getTypes(): Promise<DocumentType[]> {
    return this.documents.findTypes();
  }

  // ============================================================
  // DOCUMENTS D'UNE ENTREPRISE
  // ============================================================

  public async getCompanyDocuments(
    companyId: string,
  ): Promise<DocumentWithType[]> {
    return this.documents.findByCompanyId(companyId);
  }

  // ============================================================
  // DOCUMENT D'UNE ENTITÉ
  // ============================================================

  public async getEntityDocuments(
    entityTypeId: string,
    entityId: string,
  ): Promise<DocumentWithType[]> {
    return this.documents.findByEntity(entityTypeId, entityId);
  }

  // ============================================================
  // DOCUMENT PAR ID
  // ============================================================

  public async getById(
    companyId: string,
    id: string,
  ): Promise<DocumentWithType> {
    const document = await this.documents.findById(id);

    if (!document) {
      throw new NotFoundError("Document introuvable.");
    }

    await this.assertDocumentBelongsToCompany(companyId, document);

    return document;
  }

  // ============================================================
  // CRÉER
  // ============================================================

  public async create(
    companyId: string,
    requesterRole: string,
    input: CreateDocumentInput,
  ): Promise<string> {
    this.assertCanManage(requesterRole);

    // Le type est vérifié dans la liste des types actifs.
    const types = await this.documents.findTypes();

    const documentType = types.find((item) => item.id === input.documentTypeId);

    if (!documentType) {
      throw new NotFoundError("Type de document introuvable.");
    }

    if (!documentType.is_active) {
      throw new AuthorizationError("Ce type de document est désactivé.");
    }

    await this.assertEntityBelongsToCompany(
      companyId,
      input.entityTypeId,
      input.entityId,
    );

    if (input.expiresAt && input.issuedAt && input.expiresAt < input.issuedAt) {
      throw new AuthorizationError(
        "La date d’expiration doit être postérieure à la date d’émission.",
      );
    }

    const reminderDays =
      input.reminderDays ?? documentType.default_reminder_days;

    return this.documents.create(
      input.entityTypeId,
      input.entityId,
      input.documentTypeId,
      input.reference ?? null,
      input.issuedAt ?? null,
      input.expiresAt,
      reminderDays,
      input.notes ?? null,
      input.fileOriginalName ?? null,
      input.fileStoredName ?? null,
      input.fileStoragePath ?? null,
      input.fileMimeType ?? null,
      input.fileSize ?? null,
    );
  }

  // ============================================================
  // MODIFIER
  // ============================================================

  public async update(
    companyId: string,
    requesterRole: string,
    id: string,
    input: UpdateDocumentInput,
  ): Promise<void> {
    this.assertCanManage(requesterRole);

    const existing = await this.documents.findById(id);

    if (!existing) {
      throw new NotFoundError("Document introuvable.");
    }

    await this.assertDocumentBelongsToCompany(companyId, existing);

    const issuedAt = input.issuedAt ?? existing.issued_at;

    const expiresAt = input.expiresAt ?? existing.expires_at;

    if (expiresAt && issuedAt && expiresAt < issuedAt) {
      throw new AuthorizationError(
        "La date d’expiration doit être postérieure à la date d’émission.",
      );
    }

    const data: {
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
    } = {};

    if (input.documentTypeId !== undefined) {
      data.document_type_id = input.documentTypeId;
    }

    if (input.reference !== undefined) {
      data.reference = input.reference;
    }

    if (input.issuedAt !== undefined) {
      data.issued_at = input.issuedAt;
    }

    if (input.expiresAt !== undefined) {
      data.expires_at = input.expiresAt;
    }

    if (input.reminderDays !== undefined) {
      data.reminder_days = input.reminderDays;
    }

    if (input.fileOriginalName !== undefined) {
      data.file_original_name = input.fileOriginalName;
    }

    if (input.fileStoredName !== undefined) {
      data.file_stored_name = input.fileStoredName;
    }

    if (input.fileStoragePath !== undefined) {
      data.file_storage_path = input.fileStoragePath;
    }

    if (input.fileMimeType !== undefined) {
      data.file_mime_type = input.fileMimeType;
    }

    if (input.fileSize !== undefined) {
      data.file_size = input.fileSize;
    }

    if (input.isValid !== undefined) {
      data.is_valid = input.isValid;
    }

    if (input.notes !== undefined) {
      data.notes = input.notes;
    }

    await this.documents.update(id, data);
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================

  public async delete(
    companyId: string,
    requesterRole: string,
    id: string,
  ): Promise<void> {
    this.assertCanManage(requesterRole);

    const existing = await this.documents.findById(id);

    if (!existing) {
      throw new NotFoundError("Document introuvable.");
    }

    await this.assertDocumentBelongsToCompany(companyId, existing);

    await this.documents.delete(id);
  }

  // ============================================================
  // VÉRIFICATION ENTREPRISE
  // ============================================================

  private async assertDocumentBelongsToCompany(
    companyId: string,
    document: DocumentWithType,
  ): Promise<void> {
    await this.assertEntityBelongsToCompany(
      companyId,
      document.entity_type_id,
      document.entity_id,
    );
  }

  private async assertEntityBelongsToCompany(
    companyId: string,
    entityTypeId: string,
    entityId: string,
  ): Promise<void> {
    const documents = await this.documents.findByCompanyId(companyId);

    const belongs = documents.some(
      (document) =>
        document.entity_type_id === entityTypeId &&
        document.entity_id === entityId,
    );

    if (!belongs) {
      throw new AuthorizationError(
        "Ce document n’appartient pas à votre entreprise.",
      );
    }
  }

  // ============================================================
  // DROITS
  // ============================================================

  private assertCanManage(requesterRole: string): void {
    if (requesterRole !== "OWNER" && requesterRole !== "MANAGER") {
      throw new AuthorizationError(
        "Vous n’avez pas l’autorisation de gérer les documents.",
      );
    }
  }
}
