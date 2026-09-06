CREATE TABLE company_users (
    id CHAR(36) NOT NULL,

    company_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,

    is_pilot BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    joined_at DATETIME(6) NOT NULL,
    left_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    deleted_at DATETIME(6) NULL,

    sync_cursor BIGINT UNSIGNED NOT NULL DEFAULT 0,

    CONSTRAINT pk_company_users
        PRIMARY KEY (id),

    CONSTRAINT uq_company_users_company_user
        UNIQUE (company_id, user_id),

    INDEX idx_company_users_company (company_id),
    INDEX idx_company_users_user (user_id),
    INDEX idx_company_users_role (role_id),
    INDEX idx_company_users_pilot (is_pilot),
    INDEX idx_company_users_active (is_active),
    INDEX idx_company_users_deleted_at (deleted_at),
    INDEX idx_company_users_sync_cursor (sync_cursor),

    CONSTRAINT fk_company_users_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_company_users_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_company_users_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
