ALTER TABLE company_users
    ADD COLUMN is_pilot_active BOOLEAN NOT NULL DEFAULT FALSE
    AFTER is_pilot;

UPDATE company_users
SET is_pilot_active = is_pilot
WHERE is_pilot = TRUE;
