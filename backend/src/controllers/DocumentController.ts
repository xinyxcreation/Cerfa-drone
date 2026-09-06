import { FastifyReply, FastifyRequest } from "fastify";

import { AuthorizationError } from "../errors/AuthorizationError.js";

import {
  DocumentService,
  CreateDocumentInput,
  UpdateDocumentInput,
} from "../services/DocumentService.js";

interface AuthPayload {
  sub: string;
  company_id: string;
  role: string;
}

export class DocumentController {
  private readonly service = new DocumentService();

  private checkManagementAccess(role: string): void {
    if (role !== "OWNER" && role !== "MANAGER") {
      throw new AuthorizationError(
        "Vous n’avez pas l’autorisation de gérer les documents.",
      );
    }
  }

  // ============================================================
  // TYPES DE DOCUMENTS
  // ============================================================

  public async types(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const payload = await request.jwtVerify<AuthPayload>();

    this.checkManagementAccess(payload.role);

    const types = await this.service.getTypes();

    reply.send({
      success: true,
      document_types: types,
    });
  }

  // ============================================================
  // DOCUMENTS DE L'ENTREPRISE
  // ============================================================

  public async list(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const payload = await request.jwtVerify<AuthPayload>();

    this.checkManagementAccess(payload.role);

    const documents = await this.service.getCompanyDocuments(
      payload.company_id,
    );

    reply.send({
      success: true,
      documents,
    });
  }

  // ============================================================
  // DOCUMENT PAR ID
  // ============================================================

  public async getById(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const payload = await request.jwtVerify<AuthPayload>();

    this.checkManagementAccess(payload.role);

    const { documentId } = request.params as {
      documentId: string;
    };

    const document = await this.service.getById(payload.company_id, documentId);

    reply.send({
      success: true,
      document,
    });
  }

  // ============================================================
  // CRÉER UN DOCUMENT
  // ============================================================

  public async create(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const payload = await request.jwtVerify<AuthPayload>();

    this.checkManagementAccess(payload.role);

    const body = request.body as CreateDocumentInput;

    const id = await this.service.create(
      payload.company_id,
      payload.role,
      body,
    );

    reply.code(201).send({
      success: true,
      id,
    });
  }

  // ============================================================
  // MODIFIER UN DOCUMENT
  // ============================================================

  public async update(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const payload = await request.jwtVerify<AuthPayload>();

    this.checkManagementAccess(payload.role);

    const { documentId } = request.params as {
      documentId: string;
    };

    const body = request.body as UpdateDocumentInput;

    await this.service.update(
      payload.company_id,
      payload.role,
      documentId,
      body,
    );

    reply.send({
      success: true,
    });
  }

  // ============================================================
  // SUPPRIMER UN DOCUMENT
  // ============================================================

  public async delete(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const payload = await request.jwtVerify<AuthPayload>();

    this.checkManagementAccess(payload.role);

    const { documentId } = request.params as {
      documentId: string;
    };

    await this.service.delete(payload.company_id, payload.role, documentId);

    reply.send({
      success: true,
    });
  }
}
