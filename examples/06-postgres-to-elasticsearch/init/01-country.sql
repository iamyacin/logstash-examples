-- Minimal stand-in for the PostgreSQL "dvdrental" sample database.
-- Only the country table is needed by the Logstash example.

CREATE TABLE country (
    country_id  integer      PRIMARY KEY,
    country     varchar(50)  NOT NULL,
    last_update timestamp    NOT NULL DEFAULT now()
);

INSERT INTO country (country_id, country) VALUES
    (1,  'Afghanistan'),
    (2,  'Algeria'),
    (3,  'American Samoa'),
    (4,  'Andorra'),
    (5,  'Angola'),
    (6,  'Anguilla'),
    (7,  'Antigua and Barbuda'),
    (8,  'Argentina'),
    (9,  'Armenia'),
    (10, 'Aruba'),
    (11, 'Australia'),
    (12, 'Austria'),
    (13, 'Azerbaijan'),
    (14, 'Bahamas'),
    (15, 'Bahrain'),
    (16, 'Bangladesh'),
    (17, 'Barbados'),
    (18, 'Belarus'),
    (19, 'Belgium'),
    (20, 'Belize');
