import { z } from 'zod';

const nullableString = z
    .string()
    .trim()
    .nullable()
    .optional();

/*
 * Numéro de série constructeur
 *
 * Exemple valide :
 * 1581FB34C25CP0034ATG
 */
const serialNumber = z
    .string()
    .trim()
    .transform(value => value.toUpperCase())
    .refine(
        value => /^[A-Z0-9]{10,30}$/.test(value),
        {
            message:
                'Le numéro de série doit contenir entre 10 et 30 caractères alphanumériques.',
        },
    );

/*
 * Numéro d'enregistrement AlphaTango
 *
 * Format obligatoire :
 * UAS-FR-XXXXXX
 *
 * Exemple :
 * UAS-FR-602275
 */
const alphatangoAircraftNumber = z
    .string()
    .trim()
    .transform(value => value.toUpperCase())
    .refine(
        value => /^UAS-FR-[0-9]{6}$/.test(value),
        {
            message:
                'Le numéro d’enregistrement doit respecter le format UAS-FR-XXXXXX.',
        },
    );

/*
 * Classes européennes de drone.
 */
const droneClass = z
    .string()
    .trim()
    .transform(value => value.toUpperCase())
    .refine(
        value =>
            [
                'C0',
                'C1',
                'C2',
                'C3',
                'C4',
                'C5',
                'C6',
            ].includes(value),
        {
            message:
                'La classe du drone doit être C0, C1, C2, C3, C4, C5 ou C6.',
        },
    )
    .nullable()
    .optional();

export const CreateDroneSchema = z.object({

    nickname: nullableString,

    manufacturer: z
        .string()
        .trim()
        .min(
            1,
            'Le fabricant est obligatoire.',
        )
        .max(100),

    model: z
        .string()
        .trim()
        .min(
            1,
            'Le modèle est obligatoire.',
        )
        .max(100),

    serial_number: serialNumber,

    alphatango_aircraft_number:
        alphatangoAircraftNumber,

    drone_class: droneClass,

    weight_g: z
        .number()
        .int()
        .positive()
        .nullable()
        .optional(),

    notes: nullableString,

});

export const UpdateDroneSchema =
    CreateDroneSchema.partial();
