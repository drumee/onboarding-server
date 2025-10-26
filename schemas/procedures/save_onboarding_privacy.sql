-- File: onboarding-server/sql/procedures/save_onboarding_privacy.sql

DELIMITER $$

DROP PROCEDURE IF EXISTS `save_onboarding_privacy`$$

CREATE PROCEDURE `save_onboarding_privacy`(
    IN _user_id VARCHAR(16),
    IN _privacy_level TINYINT UNSIGNED
)
BEGIN
    -- Validate inputs 
    IF _user_id IS NULL OR _user_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_id is required';
    END IF;
    IF _privacy_level IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'privacy_level is required';
    END IF;
    IF _privacy_level < 1 OR _privacy_level > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'privacy_level must be between 1 and 5';
    END IF;

    UPDATE onboarding_responses
    SET
        privacy_concern_level = _privacy_level,
        updated_at = NOW()
    WHERE user_id = _user_id;


END$$

DELIMITER ;