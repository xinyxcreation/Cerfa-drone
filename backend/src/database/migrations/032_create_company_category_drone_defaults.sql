CREATE TABLE company_category_drone_defaults (
    company_id CHAR(36) NOT NULL,
    category_id CHAR(36) NOT NULL,
    drone_id CHAR(36) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    CONSTRAINT pk_company_category_drone_defaults
        PRIMARY KEY (company_id, category_id),

    CONSTRAINT fk_ccdd_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ccdd_category
        FOREIGN KEY (category_id)
        REFERENCES mission_categories(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ccdd_drone
        FOREIGN KEY (drone_id)
        REFERENCES drones(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_ccdd_drone (drone_id)

) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
