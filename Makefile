.PHONY: geokodikas db-production osm2pgsql export-manager
all: geokodikas db-production osm2pgsql export-manager
publish-all: geokodikas-publish db-production-publish osm2pgsql-publish export-manager-publish

geokodikas:
	cd geokodikas; docker build -t geokodikas/geokodikas:master .

geokodikas-publish:
	docker push geokodikas/geokodikas:master

db-production:
	cd db-production; docker build -t geokodikas/db-production:master .

db-production-publish:
	docker push geokodikas/db-production:master

osm2pgsql:
	cd osm2pgsql; docker build -t geokodikas/osm2pgsql:master .

osm2pgsql-publish:
	docker push geokodikas/osm2pgsql:master

export-manager:
	cd export-manager; docker build -t geokodikas/export-manager:master .

export-manager-publish:
	docker push geokodikas/export-manager:master
