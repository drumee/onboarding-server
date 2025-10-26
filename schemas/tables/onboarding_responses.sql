CREATE TABLE IF NOT EXISTS onboarding_responses (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(16) NOT NULL COMMENT 'Drumate ID from yp.drumate',
    
    -- Step 1: User Info (REQUIRED)
    first_name VARCHAR(128) NOT NULL,
    last_name VARCHAR(128) NOT NULL,
    email VARCHAR(255) NOT NULL COMMENT 'User email address',
    country VARCHAR(100) NOT NULL COMMENT 'Country name or code',
    
    -- Step 2: Usage Plan (REQUIRED)
    usage_plan ENUM('personal', 'team', 'storage', 'other') NOT NULL 
        COMMENT 'How user plans to use Drumee',
    
    -- Step 3: Current Tools (REQUIRED - JSON array, minimum empty array)
    current_tools JSON NOT NULL 
        COMMENT 'Array of tools: ["notion", "dropbox", "google_drive", "other"]',
    
    -- Step 4: Privacy Concern (REQUIRED - scale 1-5)
    privacy_concern_level TINYINT UNSIGNED NOT NULL 
        COMMENT 'Scale: 1 (Not much) to 5 (Extremely important)',
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    
    -- Constraints
    UNIQUE KEY uni_user_id (user_id),
    UNIQUE KEY uni_email (email),
    
    -- Validation
    CHECK (privacy_concern_level IS NULL OR privacy_concern_level BETWEEN 1 AND 5)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Onboarding survey responses for new Drumee users';