import { Pool } from 'mysql2/promise';

import { BaseSeeder } from '../BaseSeeder.js';
import { Seeder } from '../Seeder.js';

export class CertificationTypesSeeder extends BaseSeeder implements Seeder {

    public readonly name = 'Certification Types';

    public async run(db: Pool): Promise<void> {

        await this.insertIfNotExists(
            db,
            'certification_types',
            'code',
            'A1_A3',
            {
                code: 'A1_A3',
                label: 'CATS A1/A3',
                description: 'Certificat de compétence A1/A3',
                default_validity_days: 1825,
                    default_reminder_days: 90,
                        is_active: true,
                        sort_order: 1
            }
        );

        await this.insertIfNotExists(
            db,
            'certification_types',
            'code',
            'A2',
            {
                code: 'A2',
                label: 'CATS A2',
                description: 'Certificat de compétence A2',
                default_validity_days: 1825,
                    default_reminder_days: 90,
                        is_active: true,
                        sort_order: 2
            }
        );

        await this.insertIfNotExists(
            db,
            'certification_types',
            'code',
            'STS_01',
            {
                code: 'STS_01',
                label: 'STS-01',
                description: 'Scénario standard européen STS-01',
                default_validity_days: 1825,
                    default_reminder_days: 90,
                        is_active: true,
                        sort_order: 3
            }
        );

        await this.insertIfNotExists(
            db,
            'certification_types',
            'code',
            'STS_02',
            {
                code: 'STS_02',
                label: 'STS-02',
                description: 'Scénario standard européen STS-02',
                default_validity_days: 1825,
                    default_reminder_days: 90,
                        is_active: true,
                        sort_order: 4
            }
        );

    }

}
