# Source of base image: https://github.com/docker-library/openjdk/blob/master/11/jre/slim/Dockerfile
# Source image is based on debian:buster-slim
FROM openjdk:11-jre-slim

ENV APPLICATION_USER root
RUN mkdir -p /opt/geokodikas/ && \
    chown -R "$APPLICATION_USER" /opt/geokodikas

RUN apt-get update && \
    apt install -y --no-install-recommends netcat && \
    rm -rf /var/lib/apt/lists/*


COPY start-geokodikas.sh /opt
COPY export-manager-jar-with-dependencies.jar logback.pipeline.xml config.json /opt/geokodikas/

USER $APPLICATION_USER
WORKDIR /opt/geokodikas
EXPOSE 8080

ENV DO_NOT_COMMIT_CONTAINER yes
ENV POSTGIS_LOW_MEM yes

CMD ["/opt/start-geokodikas.sh"]
