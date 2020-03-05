FROM debian:buster-slim

ENV APPLICATION_USER geokodikas
RUN groupadd -r "$APPLICATION_USER" && \
    useradd -r -s /bin/false -g "$APPLICATION_USER" "$APPLICATION_USER" && \
    mkdir -p /opt/geokodikas/input && \
    chown -R "$APPLICATION_USER" /opt/geokodikas

WORKDIR /opt/geokodikas

# note: the actual libraries are required, but the dev packages can be removed
# run this is in one layer so that the cleanup steps actually work
RUN apt-get update && \
    apt-get install -y --no-install-recommends make cmake g++ libboost-dev libboost-filesystem1.67.0 libboost-system-dev \
      libboost-filesystem-dev libexpat1 libexpat1-dev zlib1g-dev \
      libbz2-dev libpq5 libpq-dev libproj13 libproj-dev git && \
    git clone git://github.com/openstreetmap/osm2pgsql.git && \
    cd osm2pgsql && \
    git checkout 1.0.0 && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_LUA=OFF -DWITH_LUAJIT=OFF && \
    make -j`nproc` && \
    make install && \
    chown -R "$APPLICATION_USER" /opt/geokodikas && \
    rm -rf /opt/geokodikas/osm2pgsql && \
    apt-get remove -y make cmake gcc g++ libboost-dev libboost-system-dev \
      libboost-filesystem-dev libexpat1-dev zlib1g-dev \
      libbz2-dev libpq-dev libproj-dev git && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

USER $APPLICATION_USER

COPY empty.style /opt/geokodikas/empty.style

ENV OSM2PSQL_ARGS "-S /opt/geokodikas/empty.style -lc --hstore --keep-coastlines -G --slim"
ENV OSM2PSQL_NUM_PROC "1"
ENV OSM2PSQL_CACHE_MEM "4096"
ENV PG_HOST "db"
ENV PG_NAME "geokodikas"
ENV PG_PASSWORD "geokodikas"
ENV PGPASSWORD "$PG_PASSWORD"
ENV PG_USER "geokodikas"
ENV PG_PORT "5432"

CMD ["sh", "-c", "osm2pgsql ${OSM2PSQL_ARGS} --number-processes ${OSM2PSQL_NUM_PROC} -C ${OSM2PSQL_CACHE_MEM} -P ${PG_PORT} -U ${PG_USER} -H ${PG_HOST} -d ${PG_NAME} /opt/geokodikas/input/*.pbf --prefix osm_up"]
