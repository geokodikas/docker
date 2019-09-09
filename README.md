Geokodikas Docker and Nomad
===========================

## Docker

Geokodikas can be run using Docker.

 - [geokodikas/db-production](https://hub.docker.com/r/geokodikas/db-production)
   This container contains a PostGIS server with the correct extensions installed.
   ```
   docker run -p 5432:5432  -e POSTGRES_PASSWORD='geokodikas' -e POSTGRES_USER='geokodikas' -e POSTGRES_DB='geokodikas' geokodikas/db-production:master
   ```

 - [geokodikas/geokodikas](https://hub.docker.com/r/geokodikas/geokodikas)
   This is the main Docker container which contains the geokodikas HTTP API.
   You can start this container by first creating a `config.json` file:
   ```
   {
      "importer": {
        "output_threshold": 10000,
        "max_queue_size": 1000000,
        "num_processors": 8,
        "processor_block_size": 10000
      },
      "database": {
        "username": "geokodikas",
        "password": "geokodikas",
        "db_name": "geokodikas",
        "host": "localhost",
        "port": "5432"
      },
      "import_from_export": {
        "file_location": "",
        "file_md5sum": "",
        "try_import_on_http": true
      },
      "http": {
        "public_url": "http://localhost:8080"
      }
   }
   ```
   The `file_location` and `file_md5sum` have to be configured using information available from https://github.com/geokodikas/exports.
   Then start the container with (for demonstration purposes we use `--net=host`):
   ```
   docker run --net=host -v $PWD/config.json:/opt/geokodikas/config.json -p 8080:8080 geokodikas/geokodikas:master
   ```
   If the db doesn't contain an import, this container will download the `file_location` file and import it, after which it exists.
   You can run the container again with the same command, this time the HTTP API will be started.
   The API can be reached at `http://localhost:8080`.

 - [geokodikas/osm2pgsql](https://hub.docker.com/r/geokodikas/osm2pgsql)
   Contains the [osm2pgsql](https://github.com/openstreetmap/osm2pgsql) tool used by the import pipeline.

### Docker-compose

A more robust setup can be achieved using docker-compose. An example docker-compose fill

## Nomad

The `nomad/` directory contains some example configuration for Nomad.

### Way of importing

The `geokodikas/geokodikas` docker container will read the `config.json` filled by Nomad.
This file may contain the following:
```
  "import_from_export": {
    "file_location": "https://example.com/full_importbelgium.osm.pbf_5b2197033cc053c537957d72faa2fbf8__nvaymwo4",
    "file_md5sum": "0d782ac1a1dea4d4ae8663ca7ea28d37",
    "try_import_on_http": true
  }
```
When starting, geokodikas will read the `import_from_export_metadata` table and check whether the correct import is available in the DB.
If there is no import available, geokodikas will download the configured file and start importing it in the database using `pg_restore`.
After updating the metadata table, the process will exit. Nomad will then restart the container, which will then see the import is already available
and then start the HTTP API.

In the Nomad configuration file, the database to import can be configured using the [meta keys]{https://github.com/geokodikas/docker/blob/master/nomad/geokodikas.nomad#L54}.
After changing these parameters, you can Nomad to run the new job using:
```
nomad run job geokodikas.nomad
```

The import will first be performed in a canary allocation.

### Canary updates

If you run a new plan, Nomad will create one new allocation with one canary.
Fabio will make this instance available under the `/canary` URL.
After testing whether this works, you can promote this canary version:
```
nomad job promote geokodikas
```

Be careful with canary updates with count=2, it seems that some downtime is possible then.



