import { z } from 'zod';

export const CreateClientSchema = z.object({
    customer_reference: z.string().trim().max(50).nullable().optional(),
    name: z.string().trim().min(1).max(255),
    contact_name: z.string().trim().max(255).nullable().optional(),
    email: z.string().trim().email().max(255).nullable().optional(),
    phone: z.string().trim().max(30).nullable().optional(),
    address_line_1: z.string().trim().max(255).nullable().optional(),
    address_line_2: z.string().trim().max(255).nullable().optional(),
    postal_code: z.string().trim().max(10).nullable().optional(),
    city: z.string().trim().max(150).nullable().optional(),
    country: z.string().trim().max(100).optional(),
    notes: z.string().trim().max(10000).nullable().optional(),
});

export const UpdateClientSchema =
    CreateClientSchema.partial();
