-- File: onboarding-server/schemas/tables/onboarding_responses.sql

DROP TABLE IF EXISTS onboarding_responses;

CREATE TABLE IF NOT EXISTS onboarding_responses (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(128) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'Unique session identifier',
    
    first_name VARCHAR(128) NOT NULL,
    last_name VARCHAR(128) NOT NULL,
    email VARCHAR(255) NOT NULL,
    country_code CHAR(2) NOT NULL,
    
    usage_plan ENUM('personal', 'team', 'storage', 'other') NOT NULL,
    current_tools JSON NOT NULL,
    privacy_concern_level TINYINT UNSIGNED NOT NULL,
    
    ctime INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Creation time (UNIX_TIMESTAMP)',
    mtime INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Modification time (UNIX_TIMESTAMP)',
    
    INDEX idx_session_id (session_id),
    INDEX idx_email (email),
    UNIQUE KEY uni_session_id (session_id),
    
    CHECK (privacy_concern_level BETWEEN 1 AND 5)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;