import { FastifyInstance } from "fastify";

import { AuthController } from "../controllers/AuthController.js";
import { CompanyPilotController } from "../controllers/CompanyPilotController.js";
import { CompanyMissionController } from "../controllers/CompanyMissionController.js";
import { CompanyController } from "../controllers/CompanyController.js";
import { CompanyDroneController } from "../controllers/CompanyDroneController.js";
import { CompanyMissionCategoryController } from "../controllers/CompanyMissionCategoryController.js";
import { CompanyClientController } from "../controllers/CompanyClientController.js";
import { CompanySiteController } from "../controllers/CompanySiteController.js";
import { DocumentController } from "../controllers/DocumentController.js";

export default async function authRoutes(app: FastifyInstance): Promise<void> {
  const controller = new AuthController();

  const pilotController = new CompanyPilotController();

  const companyController = new CompanyController();

  const droneController = new CompanyDroneController();

  const categoryController = new CompanyMissionCategoryController();

  const clientController = new CompanyClientController();

  const siteController = new CompanySiteController();

  const documentController = new DocumentController();

  // ============================================================
  // AUTHENTIFICATION
  // ============================================================

  app.post("/login", controller.login.bind(controller));

  app.post("/register", controller.register.bind(controller));

  // ============================================================
  // PROFIL UTILISATEUR
  // ============================================================

  app.get(
    "/me",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    controller.me.bind(controller),
  );

  app.put(
    "/me",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    controller.updateMe.bind(controller),
  );

  // ============================================================
  // STATUT PILOTE DE L'UTILISATEUR CONNECTÉ
  // ============================================================

  app.put(
    "/me/pilot",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    pilotController.activateMe.bind(pilotController),
  );

  app.delete(
    "/me/pilot",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    pilotController.deactivateMe.bind(pilotController),
  );

  // ============================================================
  // ENTREPRISE
  // ============================================================

  app.get(
    "/company",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    companyController.get.bind(companyController),
  );

  app.put(
    "/company",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    companyController.update.bind(companyController),
  );

  // ============================================================
  // DRONES DE L'ENTREPRISE
  // ============================================================

  app.get(
    "/company/drones",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.list.bind(droneController),
  );

  app.get(
    "/company/drones/:droneId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.get.bind(droneController),
  );

  app.post(
    "/company/drones",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.create.bind(droneController),
  );

  app.put(
    "/company/drones/:droneId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.update.bind(droneController),
  );

  app.patch(
    "/company/drones/:droneId/activate",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.activate.bind(droneController),
  );

  app.delete(
    "/company/drones/:droneId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.deactivate.bind(droneController),
  );

  app.delete(
    "/company/drones/:droneId/delete",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    droneController.delete.bind(droneController),
  );

  // ============================================================
  // PILOTES DE L'ENTREPRISE
  // ============================================================

  app.get("/company/pilots/certification-types", async (request, reply) =>
    pilotController.certificationTypes(request, reply),
  );

  app.get("/company/pilots/:pilotId/certifications", async (request, reply) =>
    pilotController.certifications(request, reply),
  );

  app.post("/company/pilots/:pilotId/certifications", async (request, reply) =>
    pilotController.createCertification(request, reply),
  );

  app.get(
    "/company/pilots",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    pilotController.list.bind(pilotController),
  );

  app.post(
    "/company/pilots",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    pilotController.create.bind(pilotController),
  );

  app.delete(
    "/company/pilots/:pilotId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    pilotController.deactivate.bind(pilotController),
  );

  app.patch(
    "/company/pilots/:pilotId/activate",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    pilotController.reactivate.bind(pilotController),
  );

  // ============================================================
  // SITES
  // ============================================================

  app.get("/company/sites", siteController.list.bind(siteController));

  app.post("/company/sites", siteController.create.bind(siteController));

  app.put("/company/sites/:siteId", siteController.update.bind(siteController));

  // ============================================================
  // DOCUMENTS
  // ============================================================

  app.get(
    "/company/document-types",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    documentController.types.bind(documentController),
  );

  app.get(
    "/company/documents",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    documentController.list.bind(documentController),
  );

  app.get(
    "/company/documents/:documentId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    documentController.getById.bind(documentController),
  );

  app.post(
    "/company/documents",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    documentController.create.bind(documentController),
  );

  app.patch(
    "/company/documents/:documentId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    documentController.update.bind(documentController),
  );

  app.delete(
    "/company/documents/:documentId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    documentController.delete.bind(documentController),
  );

  // ============================================================
  // CLIENTS
  // ============================================================

  app.get("/company/clients", clientController.list.bind(clientController));

  app.post("/company/clients", clientController.create.bind(clientController));

  app.put(
    "/company/clients/:clientId",
    clientController.update.bind(clientController),
  );

  // ============================================================
  // CATÉGORIES DE MISSIONS
  // ============================================================

  app.get(
    "/company/categories",
    categoryController.list.bind(categoryController),
  );

  app.post(
    "/company/categories",
    categoryController.create.bind(categoryController),
  );

  app.put(
    "/company/categories/:categoryId",
    categoryController.update.bind(categoryController),
  );

  app.patch(
    "/company/categories/:categoryId/activate",
    categoryController.activate.bind(categoryController),
  );

  app.patch(
    "/company/categories/:categoryId/deactivate",
    categoryController.deactivate.bind(categoryController),
  );

  app.delete(
    "/company/categories/:categoryId",
    categoryController.delete.bind(categoryController),
  );

  // ============================================================
  // MISSIONS
  // ============================================================

  const missionController = new CompanyMissionController();

  app.get(
    "/company/missions/references",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.references.bind(missionController),
  );

  app.get(
    "/company/missions",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.list.bind(missionController),
  );

  app.get(
    "/company/missions/:missionId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.get.bind(missionController),
  );

  app.post(
    "/company/missions",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.create.bind(missionController),
  );

  app.put(
    "/company/missions/:missionId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.update.bind(missionController),
  );

  app.patch(
    "/company/missions/:missionId/status",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.status.bind(missionController),
  );

  app.patch(
    "/company/missions/:missionId/archive",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.archive.bind(missionController),
  );

  app.delete(
    "/company/missions/:missionId",
    {
      preHandler: async (request) => {
        await request.jwtVerify();
      },
    },
    missionController.delete.bind(missionController),
  );
}
