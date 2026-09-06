import { z } from 'zod';

export const CreateSiteSchema = z.object({
    site_reference: z.string().trim().max(100).nullable().optional(),
    name: z.string().trim().min(1).max(150),
    description: z.string().trim().max(10000).nullable().optional(),
    client_id: z.string().uuid().nullable().optional(),
    category_id: z.string().uuid().nullable().optional(),
    default_drone_id: z.string().uuid().nullable().optional(),
    default_pilot_id: z.string().uuid().nullable().optional(),
    address_line_1: z.string().trim().min(1).max(255),
    address_line_2: z.string().trim().max(255).nullable().optional(),
    postal_code: z.string().trim().min(1).max(10),
    city: z.string().trim().min(1).max(150),
    country: z.string().trim().max(100).optional(),
    latitude: z.number().min(-90).max(90).nullable().optional(),
    longitude: z.number().min(-180).max(180).nullable().optional(),
    prefecture_id: z.string().uuid().nullable().optional(),
    is_favorite: z.boolean().optional(),
    notes: z.string().trim().max(10000).nullable().optional(),
});

export const UpdateSiteSchema =
    CreateSiteSchema.partial();
