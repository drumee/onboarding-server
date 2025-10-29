-- File: onboarding-server/schemas/procedures/save_onboarding_tools.sql

DROP PROCEDURE IF EXISTS `save_onboarding_tools`;

DELIMITER $$

CREATE PROCEDURE `save_onboarding_tools`(
    IN _session_id VARCHAR(128) COLLATE utf8mb4_unicode_ci,
    IN _current_tools_json TEXT
)
BEGIN
    -- Validate inputs
    IF _session_id IS NULL OR _session_id = '' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'session_id is required'; 
    END IF;
    IF _current_tools_json IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools is required'; 
    END IF;
    IF JSON_VALID(_current_tools_json) = 0 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools must be valid JSON'; 
    END IF;
    IF JSON_TYPE(_current_tools_json) != 'ARRAY' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools must be a JSON array'; 
    END IF;
    -- IF JSON_LENGTH(_current_tools_json) = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools array cannot be empty for this step'; END IF;

    -- Update current tools
    UPDATE onboarding_responses
    SET
        current_tools = _current_tools_json, 
        updated_at = NOW()
    WHERE session_id = _session_id;

END$$

DELIMITER ;