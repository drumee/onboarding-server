DROP TABLE IF EXISTS `trafic`;
CREATE TABLE `trafic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ctime` INT(11),
  `ip_address` VARCHAR(64),
  `url` TEXT,
  `referrer` TEXT,
  PRIMARY KEY (`id` ),
  UNIQUE KEY (`ip_address`, `ctime` )
) ENGINE=InnoDB DEFAULT CHARSET=ascii;
