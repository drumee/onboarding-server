
DELIMITER $

DROP PROCEDURE IF EXISTS `users_list`$
CREATE PROCEDURE `users_list`(
  _args JSON
)
BEGIN
  DECLARE _type VARCHAR(16) DEFAULT 'day';
  DECLARE _order VARCHAR(16) DEFAULT 'desc';
  DECLARE _sort_by VARCHAR(16) DEFAULT 'ctime';
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page bigint;


  SELECT IFNULL(JSON_VALUE(_args, '$.type'), "trial") INTO _type;
  SELECT IFNULL(JSON_VALUE(_args, '$.page'), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, '$.order'), "desc") INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, '$.sort_by'), "ctime") INTO _sort_by;
  CALL pageToLimits(_page, _offset, _range);

  SELECT ctime, id, email, fullname username, firstname, lastname 
    FROM yp.drumate d INNER JOIN yp.entity USING(id)
    WHERE JSON_VALUE(profile, "$.category")=_type
    ORDER BY 
      CASE WHEN LCASE(_sort_by) = 'ctime' AND LCASE(_order) = 'asc' THEN ctime END ASC,
      CASE WHEN LCASE(_sort_by) = 'ctime' AND LCASE(_order) = 'desc' THEN ctime END DESC,
      CASE WHEN LCASE(_sort_by) = 'name' AND LCASE(_order) = 'asc' THEN fullname END ASC,
      CASE WHEN LCASE(_sort_by) = 'name' AND LCASE(_order) = 'desc' THEN fullname END DESC
  LIMIT _offset, _range;
END$

DELIMITER ;
