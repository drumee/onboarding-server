DELIMITER $$

DROP PROCEDURE IF EXISTS `get_onboarding_response`$$

CREATE PROCEDURE `get_onboarding_response`(
    IN _user_id VARCHAR(16)
)
BEGIN
    -- Validate input
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
    END IF;
    
    -- Get onboarding response
    SELECT 
        id,
        user_id,
        first_name,
        last_name,
        email,
        country,
        usage_plan,
        current_tools,
        privacy_concern_level,
        created_at,
        updated_at
    FROM onboarding_responses 
    WHERE user_id = _user_id;
    
END$$

DELIMITER ;