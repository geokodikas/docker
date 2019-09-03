job "geokodikas" {

  datacenters = ["dc1"]

  # The "update" stanza specifies the update strategy of task groups. The update
  # strategy is used to control things like rolling upgrades, canaries, and
  # blue/green deployments. If omitted, no update strategy is enforced. The
  # "update" stanza may be placed at the job or task group. When placed at the
  # job, it applies to all groups within the job. When placed at both the job and
  # group level, the stanzas are merged with the group's taking precedence.
  #
  # For more information and examples on the "update" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/update.html
  #
  update {
    # The "max_parallel" parameter specifies the maximum number of updates to
    # perform in parallel. In this case, this specifies to update a single task
    # at a time.
    max_parallel = 1

    # The "min_healthy_time" parameter specifies the minimum time the allocation
    # must be in the healthy state before it is marked as healthy and unblocks
    # further allocations from being updated.
    min_healthy_time = "30s"

    # The "healthy_deadline" parameter specifies the deadline in which the
    # allocation must be marked as healthy after which the allocation is
    # automatically transitioned to unhealthy. Transitioning to unhealthy will
    # fail the deployment and potentially roll back the job if "auto_revert" is
    # set to true.
    healthy_deadline = "3m"

    # The "progress_deadline" parameter specifies the deadline in which an
    # allocation must be marked as healthy. The deadline begins when the first
    # allocation for the deployment is created and is reset whenever an allocation
    # as part of the deployment transitions to a healthy state. If no allocation
    # transitions to the healthy state before the progress deadline, the
    # deployment is marked as failed.
    progress_deadline = "10m"

    # The "auto_revert" parameter specifies if the job should auto-revert to the
    # last stable job on deployment failure. A job is marked as stable if all the
    # allocations as part of its deployment were marked healthy.
    auto_revert = false

    # The "canary" parameter specifies that changes to the job that would result
    # in destructive updates should create the specified number of canaries
    # without stopping any previous allocations. Once the operator determines the
    # canaries are healthy, they can be promoted which unblocks a rolling update
    # of the remaining allocations at a rate of "max_parallel".
    #
    # Further, setting "canary" equal to the count of the task group allows
    # blue/green deployments. When the job is updated, a full set of the new
    # version is deployed and upon promotion the old version is stopped.
    canary = 1
  }

  # The migrate stanza specifies the group's strategy for migrating off of
  # draining nodes. If omitted, a default migration strategy is applied.
  #
  # For more information on the "migrate" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/migrate.html
  #
  migrate {
    # Specifies the number of task groups that can be migrated at the same
    # time. This number must be less than the total count for the group as
    # (count - max_parallel) will be left running during migrations.
    max_parallel = 1

    # Specifies the mechanism in which allocations health is determined. The
    # potential values are "checks" or "task_states".
    health_check = "checks"

    # Specifies the minimum time the allocation must be in the healthy state
    # before it is marked as healthy and unblocks further allocations from being
    # migrated. This is specified using a label suffix like "30s" or "15m".
    min_healthy_time = "10s"

    # Specifies the deadline in which the allocation must be marked as healthy
    # after which the allocation is automatically transitioned to unhealthy. This
    # is specified using a label suffix like "2m" or "1h".
    healthy_deadline = "5m"
  }

  # The "group" stanza defines a series of tasks that should be co-located on
  # the same Nomad client. Any task within a group will be placed on the same
  # client.
  #
  # For more information and examples on the "group" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/group.html
  #
  group "geokodikas" {
    # The "count" parameter specifies the number of the task groups that should
    # be running under this group. This value must be non-negative and defaults
    # to 1.
    count = 1

    # The "restart" stanza configures a group's behavior on task failure. If
    # left unspecified, a default restart policy is used based on the job type.
    #
    # For more information and examples on the "restart" stanza, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/restart.html
    #
    restart {
      # The number of attempts to run the job within the specified interval.
      attempts = 10
      interval = "30m"

      # The "delay" parameter specifies the duration to wait before restarting
      # a task after it has failed.
      delay = "15s"

      # The "mode" parameter controls what happens when a task has restarted
      # "attempts" times within the interval. "delay" mode delays the next
      # restart until the next interval. "fail" mode does not restart the task
      # if "attempts" has been hit within the interval.
      mode = "fail"
    }

    # The "ephemeral_disk" stanza instructs Nomad to utilize an ephemeral disk
    # instead of a hard disk requirement. Clients using this stanza should
    # not specify disk requirements in the resources stanza of the task. All
    # tasks in this group will share the same ephemeral disk.
    #
    # For more information and examples on the "ephemeral_disk" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/ephemeral_disk.html
    #
    ephemeral_disk {
      # When sticky is true and the task group is updated, the scheduler
      # will prefer to place the updated allocation on the same node and
      # will migrate the data. This is useful for tasks that store data
      # that should persist across allocation updates.
      # sticky = true
      #
      # Setting migrate to true results in the allocation directory of a
      # sticky allocation directory to be migrated.
      # migrate = true

      # The "size" parameter specifies the size in MB of shared ephemeral disk
      # between tasks in the group.
      size = 300
    }

    meta {
      HASH = "de7289581d10d69dce084ca2fd0882e1"
    }

    task "db-production" {
      driver = "docker"

      config {
        image = "geokodikas/db-production:master"
        port_map {
          db = 5432
        }
	force_pull = false
        mounts = [
        {
          type = "volume"
          target = "/var/lib/postgresql/data",
          source = "db-production-pgdata-${NOMAD_META_HASH}"
          readonly = false
          volume_options {
          }
        }
        ]
      }

      env {
	POSTGRES_PASSWORD = "geokodikas"
	POSTGRES_USER     = "geokodikas"
	POSTGRES_DB       = "geokodikas"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 4000 # 256MB
        network {
          port "db" {}
        }
      }

      service {
        name = "db-production"
        tags = ["global"]
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
    "host": "{{ range service "db-production" }}{{ .Address }}{{ end }}",
    "port": "{{ range service "db-production" }}{{ .Port }}{{ end }}"
  },
  "import_from_export": {
    "file_location": "https://rpm.ledfan.be/full_importbelgium.osm.pbf_0c1d93be05ce2ce87a59b65bda77767d__t8g6pyv3",
    "file_md5sum": "de7289581d10d69dce084ca2fd0882e1",
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
        cpu    = 500 # 500 MHz
        memory = 1000 # 256MB
        network {
          port "http" {}
        }
      }

      service {
        name = "geokodikas"
        tags = ["urlprefix-/"]
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
