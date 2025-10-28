-- File: onboarding-server/schemas/tables/countries.sql

DROP TABLE IF EXISTS countries; 

CREATE TABLE IF NOT EXISTS countries (
    country_code CHAR(2) NOT NULL COMMENT 'ISO 3166-1 alpha-2 code',
    locale_code VARCHAR(10) NOT NULL COMMENT 'e.g., en_US, en_AU',
    locale_name VARCHAR(100) NOT NULL COMMENT 'Country name in the specified locale',

    PRIMARY KEY (country_code, locale_code), -- Composite Primary Key
    UNIQUE KEY uni_locale (locale_code, locale_name) -- Composite Unique Key

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stores country codes and localized names';

INSERT IGNORE INTO countries (country_code, locale_code, locale_name) VALUES
('US', 'en_US', 'United States'),
('FR', 'fr_FR', 'France'),
('DE', 'de_DE', 'Germany'),
('IT', 'it_IT', 'Italy'),
('KH','km_KH','Cambodia'),
('VN', 'vi_VN', 'Việt Nam'),
('JP', 'ja_JP', 'Japan'),
('MY', 'ms_MY', 'Malaysia'),
('RU', 'ru_RU', 'Russia'),
('AU', 'en_AU', 'Australia');
-- Will add more necessary country/locale combinations