import argon2 from 'argon2';

import { AuthorizationError } from '../errors/AuthorizationError.js';
import { ConflictError } from '../errors/ConflictError.js';
import { NotFoundError } from '../errors/NotFoundError.js';

import { CompanyRepository } from '../repositories/CompanyRepository.js';
import {
    CompanySubscriptionRepository
} from '../repositories/CompanySubscriptionRepository.js';
import { CompanyUserRepository } from '../repositories/CompanyUserRepository.js';
import { RoleRepository } from '../repositories/RoleRepository.js';
import { UserRepository } from '../repositories/UserRepository.js';

import {
    CreatePilotInput
} from '../schemas/company/CreatePilotSchema.js';

export interface CreatedPilot {

    id: string;

    email: string;
    firstname: string;
    lastname: string;
    phone: string | null;

    role: string;
    isPilot: boolean;
}

export class CompanyPilotService {

    private readonly users =
    new UserRepository();

    private readonly companies =
    new CompanyRepository();

    private readonly companyUsers =
    new CompanyUserRepository();

    private readonly roles =
    new RoleRepository();

    private readonly companySubscriptions =
    new CompanySubscriptionRepository();

    // ============================================================
    // AJOUTER / RATTACHER UN PILOTE
    // ============================================================

    public async create(
        companyId: string,
        requesterRole: string,
        input: CreatePilotInput
    ): Promise<CreatedPilot> {

        if (
            requesterRole !== 'OWNER' &&
            requesterRole !== 'MANAGER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de créer un pilote.'
            );
        }

        const company =
        await this.companies.findById(
            companyId
        );

        if (!company) {
            throw new NotFoundError(
                'Entreprise introuvable.'
            );
        }

        if (!company.is_active) {
            throw new AuthorizationError(
                'Entreprise désactivée.'
            );
        }

        // --------------------------------------------------------
        // LIMITE DU PLAN ENTREPRISE
        // --------------------------------------------------------

        const subscription =
        await this.companySubscriptions
        .findActiveByCompanyId(
            companyId
        );

        if (!subscription) {
            throw new AuthorizationError(
                'Aucun abonnement entreprise actif.'
            );
        }

        const currentPilots =
        await this.companyUsers
        .countPilotsByCompanyId(
            companyId
        );

        if (
            subscription.max_users !== null &&
            currentPilots >= subscription.max_users
        ) {
            throw new ConflictError(
                `La limite de ${subscription.max_users} utilisateur(s) de votre offre ${subscription.plan_label} est atteinte.`
            );
        }

        // --------------------------------------------------------
        // UN COMPTE EXISTE DÉJÀ
        // --------------------------------------------------------

        const existingUser =
        await this.users.findByEmail(
            input.email
        );

        // --------------------------------------------------------
        // RÔLE GÉNÉRIQUE DE L'UTILISATEUR
        // --------------------------------------------------------

        const userRole =
        await this.roles.findByCode(
            'USER'
        );

        if (!userRole) {
            throw new NotFoundError(
                'Rôle USER introuvable.'
            );
        }

        if (!userRole.is_active) {
            throw new AuthorizationError(
                'Le rôle USER est désactivé.'
            );
        }

        // --------------------------------------------------------
        // COMPTE EXISTANT
        //
        // On NE crée PAS de deuxième compte.
        // On rattache simplement l'utilisateur existant.
        // --------------------------------------------------------

        if (existingUser) {

            if (!existingUser.is_active) {
                throw new AuthorizationError(
                    'Ce compte utilisateur est désactivé.'
                );
            }

            const existingMembership =
            await this.companyUsers
            .findByCompanyAndUser(
                companyId,
                existingUser.id
            );

            // Déjà membre de l'entreprise
            if (existingMembership) {

                if (existingMembership.is_pilot) {
                    throw new ConflictError(
                        'Cet utilisateur est déjà pilote dans cette entreprise.'
                    );
                }

                await this.companyUsers.setPilot(
                    companyId,
                    existingUser.id,
                    true
                );

            } else {

                await this.companyUsers.create(
                    companyId,
                    existingUser.id,
                    userRole.id,
                    true
                );

            }

            return {

                id: existingUser.id,

                email: existingUser.email,

                firstname: existingUser.firstname,

                lastname: existingUser.lastname,

                phone: existingUser.phone,

                role: userRole.code,

                isPilot: true
            };
        }

        // --------------------------------------------------------
        // NOUVEAU COMPTE
        // --------------------------------------------------------

        const passwordHash =
        await argon2.hash(
            input.password
        );

        const userId =
        await this.users.create({

            email:
            input.email,

            password_hash:
            passwordHash,

            firstname:
            input.firstname,

            lastname:
            input.lastname,

            phone:
            input.phone ?? null

        });

        // --------------------------------------------------------
        // RATTACHEMENT À L'ENTREPRISE
        //
        // USER = rôle applicatif
        // is_pilot = fonction pilote
        // --------------------------------------------------------

        await this.companyUsers.create(
            companyId,
            userId,
            userRole.id,
            true
        );

        return {

            id:
            userId,

            email:
            input.email,

            firstname:
            input.firstname,

            lastname:
            input.lastname,

            phone:
            input.phone ?? null,

            role:
            userRole.code,

            isPilot:
            true
        };
    }

    // ============================================================
    // ACTIVER / DÉSACTIVER SON PROPRE STATUT PILOTE
    // ============================================================

    public async setCurrentUserPilot(
        companyId: string,
        userId: string,
        isPilot: boolean
    ): Promise<void> {

        const company =
        await this.companies.findById(
            companyId
        );

        if (!company) {
            throw new NotFoundError(
                'Entreprise introuvable.'
            );
        }

        if (!company.is_active) {
            throw new AuthorizationError(
                'Entreprise désactivée.'
            );
        }

        const user =
        await this.users.findById(
            userId
        );

        if (!user) {
            throw new NotFoundError(
                'Utilisateur introuvable.'
            );
        }

        if (!user.is_active) {
            throw new AuthorizationError(
                'Utilisateur désactivé.'
            );
        }

        const membership =
        await this.companyUsers.findByCompanyAndUser(
            companyId,
            userId
        );

        if (!membership) {
            throw new AuthorizationError(
                'Utilisateur non associé à cette entreprise.'
            );
        }

        await this.companyUsers.setPilot(
            companyId,
            userId,
            isPilot
        );
    }

    // ============================================================
    // DÉSACTIVER LE STATUT PILOTE
    // ============================================================

    public async deactivate(
        companyId: string,
        requesterRole: string,
        pilotId: string
    ): Promise<void> {

        if (
            requesterRole !== 'OWNER' &&
            requesterRole !== 'MANAGER'
        ) {
            throw new AuthorizationError(
                'Vous n’avez pas l’autorisation de désactiver un pilote.'
            );
        }

        const company =
        await this.companies.findById(
            companyId
        );

        if (!company) {
            throw new NotFoundError(
                'Entreprise introuvable.'
            );
        }

        if (!company.is_active) {
            throw new AuthorizationError(
                'Entreprise désactivée.'
            );
        }

        const membership =
        await this.companyUsers
        .findByCompanyAndUser(
            companyId,
            pilotId
        );

        if (!membership) {
            throw new NotFoundError(
                'Utilisateur introuvable dans cette entreprise.'
            );
        }

        if (!membership.is_pilot) {
            throw new NotFoundError(
                'Cet utilisateur n’est pas pilote dans cette entreprise.'
            );
        }

        await this.companyUsers.deactivatePilot(
            companyId,
            pilotId
        );
    }
}
