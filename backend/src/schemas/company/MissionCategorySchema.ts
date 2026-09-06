import { z } from 'zod';

export const CreateMissionCategorySchema = z.object({
    code: z.string().trim().min(1).max(50),
    label: z.string().trim().min(1).max(100),
    description: z.string().trim().max(10000).nullable().optional(),
    sort_order: z.number().int().min(0).optional(),
    default_drone_id: z.string().uuid().nullable().optional(),
});

export const UpdateMissionCategorySchema =
    CreateMissionCategorySchema.partial();
