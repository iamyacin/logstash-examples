# 06 — PostgreSQL to Elasticsearch

Query a relational table with the JDBC input and index each row. Credentials
and the driver path are supplied through environment variables, so no secrets
or binaries are committed.

| | |
|---|---|
| **Input** | PostgreSQL `dvdrental.country` table, seeded by `init/01-country.sql` |
| **Filters** | none (SQL does the shaping) |
| **Output index** | `demo-postgres-countries` |
| **Documents** | 20 |

## Run it

```bash
make up
make run EXAMPLE=06-postgres-to-elasticsearch
```

The JDBC input is a polling input, so Logstash keeps running after the first
query. Press **Ctrl+C** once the `country` rows have been logged, then check:

```bash
make count
```

## What to look at

```text
jdbc_connection_string => "jdbc:postgresql://${PG_HOST:localhost}:${PG_PORT:5432}/${PG_DATABASE:dvdrental}"
jdbc_user => "${PG_USER:logstash}"
jdbc_password => "${PG_PASSWORD:logstash}"
jdbc_driver_library => "${JDBC_DRIVER:/usr/share/logstash/drivers/postgresql.jar}"
```

- The defaults match `docker-compose.yml`; override them in `.env` or the
  shell for another database.
- The PostgreSQL JDBC driver is downloaded in `docker/logstash/Dockerfile` at
  build time. The old repo committed a 1 MB jar.
- `clean_run => true` makes every run read the full table. In production,
  remove it and use `:sql_last_value` plus a `WHERE last_update > ...` clause
  for incremental syncs.
- `document_id => "%{country_id}"` uses the primary key as the Elasticsearch
  `_id`, so repeated loads update rows instead of duplicating them.

## Try your own query

Edit `statement` in `pipeline/logstash.conf`, then rerun:

```text
statement => "SELECT country_id, country, last_update FROM country WHERE country LIKE 'A%'"
```

The init script only creates the `country` table. Point
`jdbc_connection_string` at the full `dvdrental` database if you have it
locally.

## Kibana queries

```text
country: "Belgium"
country_id <= 10
```
