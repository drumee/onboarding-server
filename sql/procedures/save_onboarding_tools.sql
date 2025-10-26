-- File: onboarding-server/sql/procedures/save_onboarding_tools.sql

DELIMITER $$

DROP PROCEDURE IF EXISTS `save_onboarding_tools`$$

CREATE PROCEDURE `save_onboarding_tools`(
    IN _user_id VARCHAR(16),
    IN _current_tools_json TEXT
)
BEGIN
    -- Validate inputs 
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
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

    UPDATE onboarding_responses
    SET
        current_tools = _current_tools_json, 
        updated_at = NOW()
    WHERE user_id = _user_id;

END$$

DELIMITER ;