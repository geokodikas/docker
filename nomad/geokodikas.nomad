job "geokodikas" {

  datacenters = ["dc1"]

  update {
    max_parallel = 1

    min_healthy_time = "30s"

    healthy_deadline = "3m"

    progress_deadline = "10m"

    auto_revert  = false

    #auto_promote = true # from 0.9.2

    canary = 1
  }

  migrate {
    max_parallel = 1

    health_check = "checks"

    min_healthy_time = "10s"

    healthy_deadline = "5m"
  }

  group "geokodikas" {
    count = 2

    restart {
      attempts = 10
      interval = "30m"

      delay = "15s"

      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }


    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    meta {
      EXPORT_URL  = "https://rpm.ledfan.be/full_importbelgium.osm.pbf_0c1d93be05ce2ce87a59b65bda77767d__t8g6pyv3"
      EXPORT_HASH = "de7289581d10d69dce084ca2fd0882e1"
      #EXPORT_URL  = "https://rpm.ledfan.be/full_importbelgium.osm.pbf_5b2197033cc053c537957d72faa2fbf8__nvaymwo4"
      #EXPORT_HASH = "0d782ac1a1dea4d4ae8663ca7ea28d37"
    }

    task "db-production" {
      driver = "docker"

      config {
        image = "geokodikas/db-production:master"
        port_map {
          db = 5432
        }
	force_pull = false
        shm_size = 512000000 # 512MB
      }

      env {
	POSTGRES_PASSWORD = "geokodikas"
	POSTGRES_USER     = "geokodikas"
	POSTGRES_DB       = "geokodikas"
      }

      resources {
        cpu    = 1024
        memory = 1000
        network {
          port "db" {}
        }
      }

      service {
        name = "db-production-${NOMAD_ALLOC_INDEX}"
        tags = ["${NOMAD_META_EXPORT_HASH}"]
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
	address_mode = "driver"
      }

    }

    task "geokodikas" {
      driver = "docker"

      config {
        image = "geokodikas/geokodikas:master"
        port_map {
          http = 8080
        }
        volumes = [
          "local/config.json:/opt/geokodikas/config.json"
        ]
	force_pull = true
        shm_size = 512000000
      }

      template {
	data = <<EOH
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
    "host": "{{ range service (printf "%s.db-production-%s" (env "NOMAD_META_EXPORT_HASH") (env "NOMAD_ALLOC_INDEX" )) }}{{ .Address }}{{ end }}",
    "port": "{{ range service (printf "%s.db-production-%s" (env "NOMAD_META_EXPORT_HASH") (env "NOMAD_ALLOC_INDEX" )) }}{{ .Port }}{{ end }}"
  },
  "import_from_export": {
    "file_location": "{{ env "NOMAD_META_EXPORT_URL" }}",
    "file_md5sum": "{{ env "NOMAD_META_EXPORT_HASH" }}",
    "try_import_on_http": true
  },
  "http": {
    "public_url": "http://localhost:9999"
  }
}

EOH
	destination = "local/config.json"
      }
      env {
        GEOKODIKAS_DB_USERNAME  = "geokodikas"
        GEOKODIKAS_DB_PASSWORD  = "geokodikas"
        GEOKODIKAS_DB_NAME      = "geokodikas"
      }

      resources {
        cpu    = 1024
        memory = 2000
        network {
          port "http" {}
        }
      }

      service {
        name = "geokodikas-${NOMAD_ALLOC_INDEX}"
        tags = ["urlprefix-/", "live", "${NOMAD_META_EXPORT_HASH}"]
        canary_tags = ["urlprefix-/canary strip=/canary", "canary", "${NOMAD_META_EXPORT_HASH}"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
