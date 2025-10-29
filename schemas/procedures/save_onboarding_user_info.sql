-- File: onboarding-server/schemas/procedures/save_onboarding_user_info.sql

DROP PROCEDURE IF EXISTS `save_onboarding_user_info`;

DELIMITER $$

CREATE PROCEDURE `save_onboarding_user_info`(
    IN _session_id VARCHAR(128) COLLATE utf8mb4_unicode_ci,
    IN _first_name VARCHAR(128),
    IN _last_name VARCHAR(128),
    IN _email VARCHAR(255),
    IN _country_code CHAR(2)
)
BEGIN
    -- Validate inputs
    IF _session_id IS NULL OR _session_id = '' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'session_id is required'; 
    END IF;
    
    IF _first_name IS NULL OR _first_name = '' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'first_name is required'; 
    END IF;
    
    IF _last_name IS NULL OR _last_name = '' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'last_name is required'; 
    END IF;
    
    IF _email IS NULL OR _email = '' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'email is required'; 
    END IF;
    
    IF _country_code IS NULL OR _country_code = '' OR LENGTH(_country_code) != 2 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valid 2-letter country_code is required'; 
    END IF;
    
    IF _email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format'; 
    END IF;

    -- Validate country_code exists
    IF NOT EXISTS (SELECT 1 FROM countries WHERE country_code = _country_code) THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid country_code provided'; 
    END IF;

    -- Insert with TEMPORARY DEFAULT VALUES
    INSERT INTO onboarding_responses (
        session_id,
        first_name,
        last_name,
        email,
        country_code,
        usage_plan,
        current_tools,
        privacy_concern_level
    )
    VALUES (
        _session_id,
        _first_name,
        _last_name,
        _email,
        _country_code,
        'personal',
        JSON_ARRAY(),
        1
    )
    ON DUPLICATE KEY UPDATE
        first_name = VALUES(first_name),
        last_name = VALUES(last_name),
        email = VALUES(email),
        country_code = VALUES(country_code),
        updated_at = NOW();

END$$

DELIMITER ;