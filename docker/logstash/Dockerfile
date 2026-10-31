ARG ELASTIC_VERSION=9.5.5
FROM docker.elastic.co/logstash/logstash:${ELASTIC_VERSION}

# The JDBC input plugin is bundled with Logstash, but the PostgreSQL driver
# is not. Download it at build time instead of committing a 1 MB jar.
USER root
RUN mkdir -p /usr/share/logstash/drivers \
    && rm -f /usr/share/logstash/pipeline/logstash.conf

ADD https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar /usr/share/logstash/drivers/postgresql.jar

RUN chown -R logstash:logstash /usr/share/logstash/drivers
USER logstash
