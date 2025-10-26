-- File: onboarding-server/sql/procedures/save_onboarding_user_info.sql

DELIMITER $$

DROP PROCEDURE IF EXISTS `save_onboarding_user_info`$$

CREATE PROCEDURE `save_onboarding_user_info`(
    IN _user_id VARCHAR(16),
    IN _first_name VARCHAR(128),
    IN _last_name VARCHAR(128),
    IN _email VARCHAR(255),
    IN _country VARCHAR(100)
)
BEGIN
    -- Validate inputs 
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
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
    IF _country IS NULL OR _country = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'country is required';
    END IF;
    IF _email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format';
    END IF;

    -- Insert with TEMPORARY DEFAULT VALUES 
    INSERT INTO onboarding_responses (
        user_id,
        first_name,
        last_name,
        email,
        country,
        usage_plan,
        current_tools,
        privacy_concern_level
    )
    VALUES (
        _user_id,
        _first_name,
        _last_name,
        _email,
        _country,
        'personal',
        JSON_ARRAY(),
        1
    )
    ON DUPLICATE KEY UPDATE
        first_name = VALUES(first_name),
        last_name = VALUES(last_name),
        email = VALUES(email),
        country = VALUES(country),
        updated_at = NOW();

END$$

DELIMITER ;