-- File: onboarding-server/schemas/procedures/save_onboarding_privacy.sql

DROP PROCEDURE IF EXISTS `save_onboarding_privacy`;

DELIMITER $$

CREATE PROCEDURE `save_onboarding_privacy`(
    IN _session_id VARCHAR(128) COLLATE utf8mb4_unicode_ci,
    IN _privacy_level TINYINT UNSIGNED
)
BEGIN
    -- Validate inputs
    IF _session_id IS NULL OR _session_id = '' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'session_id is required'; 
    END IF;
    IF _privacy_level IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'privacy_level is required'; 
    END IF;
    IF _privacy_level < 1 OR _privacy_level > 5 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'privacy_level must be between 1 and 5'; 
    END IF;

    -- Update privacy level
    UPDATE onboarding_responses
    SET
        privacy_concern_level = _privacy_level,
        updated_at = NOW()
    WHERE session_id = _session_id;

END$$

DELIMITER ;