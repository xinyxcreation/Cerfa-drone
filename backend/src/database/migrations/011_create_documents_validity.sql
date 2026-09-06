CREATE TABLE documents_validity (
    id CHAR(36) NOT NULL,

    entity_type_id CHAR(36) NOT NULL,
    entity_id CHAR(36) NOT NULL,

    document_type_id CHAR(36) NOT NULL,

    reference VARCHAR(100) NULL,

    issued_at DATE NULL,
    expires_at DATE NOT NULL,

    reminder_days SMALLINT UNSIGNED NULL,

    file_original_name VARCHAR(255) NULL,
    file_stored_name VARCHAR(255) NULL,
    file_storage_path VARCHAR(500) NULL,
    file_mime_type VARCHAR(100) NULL,
    file_size BIGINT UNSIGNED NULL,

    is_valid BOOLEAN NOT NULL DEFAULT TRUE,

    notes TEXT NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    deleted_at DATETIME(6) NULL,

    sync_cursor BIGINT UNSIGNED NOT NULL DEFAULT 0,

    CONSTRAINT pk_documents_validity
        PRIMARY KEY (id),

    INDEX idx_documents_validity_entity (entity_type_id, entity_id),
    INDEX idx_documents_validity_document_type (document_type_id),
    INDEX idx_documents_validity_expires_at (expires_at),
    INDEX idx_documents_validity_valid (is_valid),
    INDEX idx_documents_validity_deleted_at (deleted_at),
    INDEX idx_documents_validity_sync_cursor (sync_cursor),

    CONSTRAINT fk_documents_validity_entity_type
        FOREIGN KEY (entity_type_id)
        REFERENCES entity_types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_documents_validity_document_type
        FOREIGN KEY (document_type_id)
        REFERENCES document_types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
