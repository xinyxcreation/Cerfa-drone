import { z } from 'zod';

export const CreateCertificationSchema = z.object({

    code: z
        .string()
        .trim()
        .min(1),

    obtained_at: z
        .string()
        .min(1),

    expires_at: z
        .string()
        .nullable()
        .optional(),

    reminder_days: z
        .number()
        .int()
        .min(0)
        .nullable()
        .optional(),

    notes: z
        .string()
        .trim()
        .nullable()
        .optional()

});

export const UpdateCertificationSchema =
    CreateCertificationSchema.partial();
