# Source of base image: https://github.com/docker-library/openjdk/blob/master/11/jre/slim/Dockerfile
# Source image is based on debian:buster-slim
FROM openjdk:11-jre-slim

ENV APPLICATION_USER geokodikas
RUN groupadd -r "$APPLICATION_USER" && \
    useradd -r -s /bin/false -g "$APPLICATION_USER" "$APPLICATION_USER" && \
    mkdir -p /opt/geokodikas/ && \
    chown -R "$APPLICATION_USER" /opt/geokodikas

RUN apt-get update && \
    apt install -y --no-install-recommends netcat postgresql-client && \
    rm -rf /var/lib/apt/lists/*

COPY http-api-jar-with-dependencies.jar logback.xml config.json /opt/geokodikas/

COPY ./start-geokodikas.sh /opt/

USER $APPLICATION_USER
WORKDIR /opt/geokodikas
EXPOSE 8080

CMD ["/opt/start-geokodikas.sh"]
