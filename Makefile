.PHONY: geokodikas db-production osm2pgsql ci-export-manager
all: geokodikas db-production osm2pgsql ci-export-manager
publish-all: geokodikas-publish db-production-publish osm2pgsql-publish export-manager-publish

geokodikas:
	cp ../geokodikas/target/rest-api-jar-with-dependencies.jar geokodikas/
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

ci-export-manager:
	cp ../geokodikas/target/from-yaml-jar-with-dependencies.jar ci-export-manager/
	cd ci-export-manager; docker build -t geokodikas/ci-export-manager:master .

ci-export-manager-publish:
	docker push geokodikas/ci-export-manager:master
