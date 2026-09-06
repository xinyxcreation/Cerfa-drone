import { Pool } from "mysql2/promise";

import { BaseSeeder } from "../BaseSeeder.js";
import { Seeder } from "../Seeder.js";

export class DocumentTypesSeeder extends BaseSeeder implements Seeder {
  public readonly name = "Document Types";

  public async run(db: Pool): Promise<void> {
    const userId = await this.getIdByCode(db, "entity_types", "PILOT");

    const droneId = await this.getIdByCode(db, "entity_types", "DRONE");

    const companyId = await this.getIdByCode(db, "entity_types", "COMPANY");

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "PILOT_LICENSE",
      {
        entity_type_id: userId,
        code: "PILOT_LICENSE",
        label: "Attestation de pilote",
        description: "Attestation de compétences du pilote.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: true,
        is_active: true,
        sort_order: 1,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "PILOT_INSURANCE",
      {
        entity_type_id: userId,
        code: "PILOT_INSURANCE",
        label: "Assurance pilote",
        description: "Assurance responsabilité civile du pilote.",
        default_validity_days: 365,
        default_reminder_days: 30,
        is_required: true,
        is_active: true,
        sort_order: 2,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "DRONE_REGISTRATION",
      {
        entity_type_id: droneId,
        code: "DRONE_REGISTRATION",
        label: "Enregistrement drone",
        description: "Justificatif d’enregistrement du drone.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: true,
        is_active: true,
        sort_order: 3,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "DRONE_INSURANCE",
      {
        entity_type_id: droneId,
        code: "DRONE_INSURANCE",
        label: "Assurance drone",
        description: "Assurance responsabilité civile du drone.",
        default_validity_days: 365,
        default_reminder_days: 30,
        is_required: true,
        is_active: true,
        sort_order: 4,
      },
    );

    await this.insertIfNotExists(db, "document_types", "code", "MANEX", {
      entity_type_id: companyId,
      code: "MANEX",
      label: "MANEX",
      description: "Manuel d’exploitation.",
      default_validity_days: null,
      default_reminder_days: 30,
      is_required: false,
      is_active: true,
      sort_order: 5,
    });

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "PILOT_IDENTITY_FRONT",
      {
        entity_type_id: userId,
        code: "PILOT_IDENTITY_FRONT",
        label: "Carte d’identité — recto",
        description:
          "Copie du recto de la carte nationale d’identité du pilote.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: false,
        is_active: true,
        sort_order: 6,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "PILOT_IDENTITY_BACK",
      {
        entity_type_id: userId,
        code: "PILOT_IDENTITY_BACK",
        label: "Carte d’identité — verso",
        description:
          "Copie du verso de la carte nationale d’identité du pilote.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: false,
        is_active: true,
        sort_order: 7,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "FLIGHT_AUTHORIZATION",
      {
        entity_type_id: companyId,
        code: "FLIGHT_AUTHORIZATION",
        label: "Autorisation de vol",
        description:
          "Autorisation ou accord nécessaire pour réaliser une opération de vol.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: false,
        is_active: true,
        sort_order: 8,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "SITE_ACCESS_AUTHORIZATION",
      {
        entity_type_id: companyId,
        code: "SITE_ACCESS_AUTHORIZATION",
        label: "Autorisation d’accès au site",
        description:
          "Autorisation d’accès à un site sensible, militaire ou soumis à contrôle.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: false,
        is_active: true,
        sort_order: 9,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "SITE_SPECIFIC_DOCUMENT",
      {
        entity_type_id: companyId,
        code: "SITE_SPECIFIC_DOCUMENT",
        label: "Document spécifique au site",
        description:
          "Document demandé spécifiquement pour un site ou une mission.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: false,
        is_active: true,
        sort_order: 10,
      },
    );

    await this.insertIfNotExists(
      db,
      "document_types",
      "code",
      "OTHER_DOCUMENT",
      {
        entity_type_id: companyId,
        code: "OTHER_DOCUMENT",
        label: "Autre document",
        description:
          "Document complémentaire ne correspondant pas à un type prédéfini.",
        default_validity_days: null,
        default_reminder_days: 30,
        is_required: false,
        is_active: true,
        sort_order: 11,
      },
    );
  }
}
