# Source of base image: https://github.com/docker-library/postgres/blob/master/11/Dockerfile
# Source image is based on debian:stretch-slim
# Dockerfile derived from: https://github.com/appropriate/docker-postgis/blob/master/11-2.5/Dockerfile (MIT)
FROM postgres:11

ENV POSTGIS_MAJOR 2.5
ENV POSTGIS_VERSION 2.5.4+dfsg-1.pgdg90+1

RUN echo "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backport.list \
  && apt-get update \
  && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
  && apt-get -t stretch-backports install -y libsfcgal1 \
  && apt-get install -y --no-install-suggests --no-install-recommends \
       postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
       postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin
