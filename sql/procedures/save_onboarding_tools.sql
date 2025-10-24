DELIMITER $$

DROP PROCEDURE IF EXISTS `save_onboarding_tools`$$

CREATE PROCEDURE `save_onboarding_tools`(
    IN _user_id VARCHAR(16),
    IN _current_tools_json TEXT 
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validate inputs
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
    END IF;
    
    IF _current_tools_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools is required';
    END IF;
    
    -- Validate JSON is valid and is an array
    IF JSON_VALID(_current_tools_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools must be valid JSON';
    END IF;
    
    IF JSON_TYPE(_current_tools_json) != 'ARRAY' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'current_tools must be a JSON array';
    END IF;
    
    -- Check if record exists
    IF NOT EXISTS (SELECT 1 FROM onboarding_responses WHERE user_id = _user_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User info must be saved first (Step 1)';
    END IF;
    
    -- Update current tools - Cast TEXT to JSON
    UPDATE onboarding_responses 
    SET 
        current_tools = CAST(_current_tools_json AS JSON),
        updated_at = NOW()
    WHERE user_id = _user_id;
    
    COMMIT;
    
    -- Return the record
    SELECT * FROM onboarding_responses WHERE user_id = _user_id;
    
END$$

DELIMITER ;