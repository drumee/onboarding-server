DELIMITER $$

DROP PROCEDURE IF EXISTS `check_onboarding_completion`$$

CREATE PROCEDURE `check_onboarding_completion`(
    IN _user_id VARCHAR(16)
)
BEGIN
    DECLARE v_completed BOOLEAN DEFAULT FALSE;
    
    -- Validate input
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
    END IF;
    
    -- Check if all required fields are filled
    SELECT 
        CASE 
            WHEN first_name IS NOT NULL 
                AND last_name IS NOT NULL 
                AND email IS NOT NULL 
                AND country IS NOT NULL
                AND usage_plan IS NOT NULL
                AND current_tools IS NOT NULL
                AND privacy_concern_level IS NOT NULL
            THEN TRUE
            ELSE FALSE
        END INTO v_completed
    FROM onboarding_responses 
    WHERE user_id = _user_id;
    
    -- Return completion status
    SELECT 
        _user_id as user_id,
        COALESCE(v_completed, FALSE) as is_completed,
        CASE 
            WHEN v_completed IS NULL THEN 'not_started'
            WHEN v_completed = TRUE THEN 'completed'
            ELSE 'incomplete'
        END as status;
    
END$$

DELIMITER ;