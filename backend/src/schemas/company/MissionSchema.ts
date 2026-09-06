import { z } from 'zod';

const nullableString = z
    .string()
    .trim()
    .nullable()
    .optional();

export const CreateMissionSchema = z.object({

    client_id:
        z.string()
        .uuid(),

    pilot_id:
        z.string()
        .uuid(),

    category_id:
        z.string()
        .uuid(),

    mission_status_id:
        z.string()
        .uuid()
        .optional(),

    reference:
        nullableString,

    title:
        z.string()
        .trim()
        .min(1)
        .max(255),

    description:
        nullableString,

    planned_at:
        z.string()
        .datetime()
        .nullable()
        .optional(),

    notes:
        nullableString,

    location: z.object({

        site_id:
            z.string()
            .uuid()
            .nullable()
            .optional(),

        drone_id:
            z.string()
            .uuid(),

        prefecture_id:
            z.string()
            .uuid(),

        name:
            nullableString,

        address_line_1:
            z.string()
            .trim()
            .min(1)
            .max(255),

        address_line_2:
            nullableString,

        postal_code:
            z.string()
            .trim()
            .min(1)
            .max(10),

        city:
            z.string()
            .trim()
            .min(1)
            .max(150),

        country:
            z.string()
            .trim()
            .max(100)
            .default('France'),

        latitude:
            z.number()
            .nullable()
            .optional(),

        longitude:
            z.number()
            .nullable()
            .optional(),

        notes:
            nullableString

    })

});

export const UpdateMissionSchema =
    CreateMissionSchema.partial().extend({

        location:
            CreateMissionSchema.shape.location
            .partial()
            .optional()

    });

export const UpdateMissionStatusSchema = z.object({

    mission_status_id:
        z.string()
        .uuid()

});

export type CreateMissionInput =
    z.infer<typeof CreateMissionSchema>;

export type UpdateMissionInput =
    z.infer<typeof UpdateMissionSchema>;

export type UpdateMissionStatusInput =
    z.infer<typeof UpdateMissionStatusSchema>;
