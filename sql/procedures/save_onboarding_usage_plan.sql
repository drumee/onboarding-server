DELIMITER $$

DROP PROCEDURE IF EXISTS `save_onboarding_usage_plan`$$

CREATE PROCEDURE `save_onboarding_usage_plan`(
    IN _user_id VARCHAR(16),
    IN _usage_plan ENUM('personal', 'team', 'storage', 'other')
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
    
    IF _usage_plan IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'usage_plan is required';
    END IF;
    
    -- Check if record exists
    IF NOT EXISTS (SELECT 1 FROM onboarding_responses WHERE user_id = _user_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User info must be saved first (Step 1)';
    END IF;
    
    -- Update usage plan
    UPDATE onboarding_responses 
    SET 
        usage_plan = _usage_plan,
        updated_at = NOW()
    WHERE user_id = _user_id;
    
    COMMIT;
    
    -- Return the record
    SELECT * FROM onboarding_responses WHERE user_id = _user_id;
    
END$$

DELIMITER ;