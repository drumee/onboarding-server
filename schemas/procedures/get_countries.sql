-- File: onboarding-server/sql/procedures/get_countries.sql
DROP PROCEDURE IF EXISTS `get_countries`;

DELIMITER $$

CREATE PROCEDURE `get_countries`(
    IN _locale_code VARCHAR(10) 
)
BEGIN
    IF _locale_code IS NULL OR _locale_code = '' THEN
        SELECT 
            country_code, 
            locale_code, 
            locale_name 
        FROM countries
        ORDER BY locale_name ASC; 
    ELSE
        SELECT 
            country_code, 
            locale_code, 
            locale_name 
        FROM countries
        WHERE locale_code = _locale_code
        ORDER BY locale_name ASC;
    END IF;
END$$

DELIMITER ;