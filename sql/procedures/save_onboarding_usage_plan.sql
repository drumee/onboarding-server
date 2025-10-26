-- File: onboarding-server/sql/procedures/save_onboarding_usage_plan.sql

DELIMITER $$

DROP PROCEDURE IF EXISTS `save_onboarding_usage_plan`$$

CREATE PROCEDURE `save_onboarding_usage_plan`(
    IN _user_id VARCHAR(16),
    IN _usage_plan ENUM('personal', 'team', 'storage', 'other')
)
BEGIN
    -- Validate inputs
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
    END IF;
    IF _usage_plan IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'usage_plan is required';
    END IF;

    UPDATE onboarding_responses
    SET
        usage_plan = _usage_plan,
        updated_at = NOW()
    WHERE user_id = _user_id;


END$$

DELIMITER ;