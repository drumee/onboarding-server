DROP PROCEDURE IF EXISTS `save_signup_info`;

DELIMITER $$

CREATE PROCEDURE `save_signup_info`(
    IN _session_id VARCHAR(128) CHARACTER SET ascii,
    IN _email VARCHAR(255) CHARACTER SET ascii
)
BEGIN
  DECLARE _otp VARCHAR(10);

  SELECT GROUP_CONCAT(
    ROUND(RAND()*9), ROUND(RAND()*9),ROUND(RAND()*9), ROUND(RAND()*9),ROUND(RAND()*9), ROUND(RAND()*9)
  ) INTO _otp;

  INSERT INTO signup_data (
    session_id,
    email,
    otp
  )
  VALUES (
    _session_id,
    _email,
    _otp
  )
  ON DUPLICATE KEY UPDATE
    email = VALUES(email), session_id=VALUES(session_id), otp=VALUES(otp);
  
  SELECT otp, email FROM signup_data WHERE session_id=_session_id;

END$$

DELIMITER ;