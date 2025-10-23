
DELIMITER $

DROP PROCEDURE IF EXISTS `trafic_history`$
CREATE PROCEDURE `trafic_history`(
  _args JSON
)
BEGIN
  DECLARE _type VARCHAR(16) DEFAULT 'day';
  DECLARE _referrer VARCHAR(16);
  DECLARE _url VARCHAR(16);
  DECLARE _start VARCHAR(16);
  DECLARE _end VARCHAR(16);
  DECLARE _start_ts INT(11);
  DECLARE _end_ts INT(11);
  DECLARE _interval INT(11) DEFAULT 3;

  SELECT JSON_VALUE(_args, '$.type') INTO _type;
  SELECT JSON_VALUE(_args, '$.start') INTO _start;
  SELECT JSON_VALUE(_args, '$.end') INTO _end;
  SELECT JSON_VALUE(_args, '$.referrer') INTO _referrer;
  SELECT JSON_VALUE(_args, '$.url') INTO _url;
  SELECT IFNULL(JSON_VALUE(_args, '$.interval'), 3) INTO _interval;
  
  
  SET _start_ts = UNIX_TIMESTAMP(_start);
  SET _end_ts = UNIX_TIMESTAMP(_end);

  IF _start_ts IS NULL THEN
    SELECT CASE 
      WHEN _type = 'minute' THEN  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval MINUTE))
      WHEN _type = 'hour' THEN  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval HOUR))
      WHEN _type = 'day' THEN  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval DAY))
      WHEN _type = 'week' THEN  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval WEEK))
      WHEN _type = 'month' THEN  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval MONTH))
      WHEN _type = 'year' THEN  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval YEAR))
      ELSE  UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL _interval YEAR))
    END INTO _start_ts;
  END IF;

  IF _end_ts IS NULL THEN
    SET _end_ts = UNIX_TIMESTAMP();
  END IF;

  SET @format='%Y';
  SELECT CASE 
    WHEN _type = 'minute' THEN  '%Y-%m-%d %H:%i'
    WHEN _type = 'hour' THEN  '%Y-%m-%d:%H'
    WHEN _type = 'day' THEN  '%Y-%m-%d'
    WHEN _type = 'week' THEN  '%Y-%u'
    WHEN _type = 'month' THEN  '%Y-%m'
    WHEN _type = 'year' THEN  '%Y'
    ELSE  '%Y-%m-%d'
  END INTO @format;

  SET @period='%Y';
  SELECT CASE 
    WHEN _type = 'minute' THEN  '%i'
    WHEN _type = 'hour' THEN  '%H'
    WHEN _type = 'day' THEN  '%d'
    WHEN _type = 'week' THEN  '%u'
    WHEN _type = 'month' THEN  '%m'
    WHEN _type = 'year' THEN  '%Y'
    ELSE  '%Y-%m-%d'
  END INTO @period;

  SELECT 
      `period`,
      year,
      month,
      day,
      hour,
      minute,
      instant,
      @running_total := @running_total + instant AS cumulative
  FROM (
      SELECT 
        FROM_UNIXTIME(ctime, @period) AS `period`,
        FROM_UNIXTIME(ctime, '%Y') AS year,
        FROM_UNIXTIME(ctime, '%m') AS month,
        FROM_UNIXTIME(ctime, '%d') AS day,
        FROM_UNIXTIME(ctime, '%H') AS hour,
        FROM_UNIXTIME(ctime, '%i') AS minute,
        COUNT(DISTINCT id) AS instant
      FROM trafic
      WHERE ctime BETWEEN _start_ts AND _end_ts AND
      IF(_referrer IS NULL, 1, referrer REGEXP _referrer) AND
      IF(_url IS NULL, 1, url REGEXP _url)
      GROUP BY FROM_UNIXTIME(ctime, @format)
      ORDER BY `period`
  ) instant
  CROSS JOIN (SELECT @running_total := 0) rt
  ORDER BY `period`;

END$

DELIMITER ;
