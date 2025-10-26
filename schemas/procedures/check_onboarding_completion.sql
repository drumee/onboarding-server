-- File: onboarding-server/sql/procedures/check_onboarding_completion.sql

DELIMITER $$

DROP PROCEDURE IF EXISTS `check_onboarding_completion`$$

CREATE PROCEDURE `check_onboarding_completion`(
    IN _user_id VARCHAR(16)
)
BEGIN
    DECLARE v_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_usage_plan VARCHAR(20);
    DECLARE v_tools_count INT DEFAULT 0;
    DECLARE v_privacy INT;
    DECLARE v_completed BOOLEAN DEFAULT FALSE;

    -- Validate input
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
    END IF;

    -- Check if record exists
    SELECT COUNT(*) > 0 INTO v_exists
    FROM onboarding_responses
    WHERE user_id = _user_id;

    IF NOT v_exists THEN
        -- Not started - return early
        SELECT
            _user_id as user_id,
            FALSE as is_completed,
            'not_started' as status,
            NULL as steps_completed;
    ELSE
        -- Record exists - check completion
        SELECT
            usage_plan,
            JSON_LENGTH(current_tools),
            privacy_concern_level
        INTO v_usage_plan, v_tools_count, v_privacy
        FROM onboarding_responses
        WHERE user_id = _user_id;

        SET v_completed = (v_tools_count > 0);

        SELECT
            _user_id as user_id,
            v_completed as is_completed,
            CASE
                WHEN v_completed THEN 'completed'
                ELSE 'incomplete'
            END as status,
            JSON_OBJECT(
                'step1_user_info', TRUE,
                'step2_usage_plan', TRUE,
                'step3_tools', (v_tools_count > 0),
                'step4_privacy', TRUE
            ) as steps_completed;
    END IF;

END$$

DELIMITER ;