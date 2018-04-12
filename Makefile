# Notes:
# assumes direnv hook already exists

SHELL := /bin/bash
peldir := ${HOME}/local/pelias
node6_latest := $(shell curl -s https://nodejs.org/dist/latest-v6.x/ | grep -P 'linux-x64\.tar\.gz' | sed -n 1p | cut -d '"' -f 2)
direnv_latest := $(shell curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep 'browser_download_url' | grep 'linux-amd64' | cut -d '"' -f 4)
datadir := /disk/agebulk1/medicare.work/doyle-DUA18266/barronk/raw/pelias

PELIAS_DEPS := .envrc $(peldir)/bin/node
PELIAS_DEPS += $(peldir)/elasticsearch/bin/elasticsearch
PELIAS_DEPS += api schema whosonfirst openaddresses openstreetmap polylines
PELIAS_DEPS += $(HOME)/pelias.json

.pelias_finished_install: $(PELIAS_DEPS)
	touch .pelias_finished_install
	@ echo "Done"

DOWNLOAD_DEPS := .pelias_finished_install
download:
	make .download_whosonfirst
	make .download_openaddresses
	make .download_openstreetmap
	make .download_polylines

api:
	git clone git@github.com:pelias/api.git
	cd api; \
	git checkout production; \
	npm install; \
	echo 'export CC="gcc"' > .envrc; \
	echo 'export CXX="g++"' >> .envrc; \
	echo 'export CXXFLAGS=-I$$(pwd)/node_modules/node-postal/deps/include' >> .envrc; \
	echo 'export LDFLAGS=-L$$(pwd)/node_modules/node-postal/deps/lib' >> .envrc; \
	echo 'export LD_LIBRARY_PATH=$$(pwd)/node_modules/node-postal/deps/lib:$$LD_LIBRARY_PATH' >> .envrc; \
	direnv allow; \
	cd node_modules/node-postal; \
	export CC="gcc"; \
	export CXX="g++"; \
	mkdir deps; \
	git clone git@github.com:openvenues/libpostal.git; \
	cd libpostal; \
	./bootstrap.sh; \
	autoreconf -i; \
	cat m4/libtool.m4 >> aclocal.m4; \
	cat m4/ltoptions.m4 >> aclocal.m4; \
	cat m4/ltversion.m4 >> aclocal.m4; \
	cat m4/lt\~obsolete.m4 >> aclocal.m4; \
	./configure --datadir=$$(pwd)/data --prefix=$$(pwd)/../deps --bindir=$$(pwd)/../deps; \
	make -j4; \
	make install; \
	cd ..; \
	export CXXFLAGS=-I$$(pwd)/deps/include; \
    export LDFLAGS=-L$$(pwd)/deps/lib; \
	npm install; \
	cd ../../; \
	cd ..;

schema:
	git clone git@github.com:pelias/schema.git
	cd schema; \
	git checkout production; \
	npm install; \
	cd ..;

whosonfirst:
	git clone git@github.com:pelias/whosonfirst.git
	cd whosonfirst; \
	git checkout production; \
	npm install; \
	cd ..;

openaddresses:
	git clone git@github.com:pelias/openaddresses.git
	cd openaddresses; \
	git checkout production; \
	npm install; \
	cd ..;

openstreetmap:
	git clone git@github.com:pelias/openstreetmap.git
	cd openstreetmap; \
	git checkout production; \
	npm install; \
	cd ..;

polylines:
	git clone git@github.com:pelias/polylines.git
	cd polylines; \
	git checkout production; \
	npm install; \
	cd ..;

$(HOME)/pelias.json:
	bash ./create_pelias_config.sh -d $(datadir)


.download_whosonfirst: $(HOME)/pelias.json
	cd whosonfirst; \
	npm run download
	touch .download_whosonfirst

.download_openaddresses:
	mkdir -p $(datadir)/openaddresses/
	wget https://s3.amazonaws.com/data.openaddresses.io/openaddr-collected-us_northeast.zip -P $(datadir)/openaddresses/
	wget https://s3.amazonaws.com/data.openaddresses.io/openaddr-collected-us_midwest.zip -P $(datadir)/openaddresses/
	wget https://s3.amazonaws.com/data.openaddresses.io/openaddr-collected-us_south.zip -P $(datadir)/openaddresses/
	wget https://s3.amazonaws.com/data.openaddresses.io/openaddr-collected-us_west.zip -P $(datadir)/openaddresses/
	cd $datadir/openaddresses; \
	unzip -n "*.zip"; \
	rm -f *.zip
	python ./openaddresses_update.py
	touch .download_openaddresses

.download_openstreetmap:
	mkdir -p $(datadir)/openstreetmap/
	wget https://download.geofabrik.de/north-america/us-midwest-latest.osm.pbf -P $(datadir)/openstreetmap
	wget https://download.geofabrik.de/north-america/us-northeast-latest.osm.pbf -P $(datadir)/openstreetmap
	wget https://download.geofabrik.de/north-america/us-south-latest.osm.pbf -P $(datadir)/openstreetmap
	wget https://download.geofabrik.de/north-america/us-west-latest.osm.pbf -P $(datadir)/openstreetmap
	touch .download_openstreetmap

.download_polylines:
	mkdir -p $(datadir)/polylines/
	wget http://pelias-data.nextzen.org.s3.amazonaws.com/poylines/road_network.gz -P $(datadir)/polylines/
	gunzip $(datadir)/polylines/road_network.gz
	mv $(datadir)/polylines/road_network $(datadir)/polylines/road_network.polylines
	touch .download_polylines

.envrc:
	mkdir -p $(peldir)/bin
	wget $(direnv_latest) -O $(peldir)/bin/direnv
	echo 'export PATH=$(peldir)/bin:$$PATH' > .envrc
	direnv allow


$(peldir)/bin/node:
	echo $(node6_latest)
	wget https://nodejs.org/dist/latest-v6.x/$(node6_latest) -O /tmp/node-v6.tar.gz
	
	mkdir -p /tmp/node
	tar -xzvf /tmp/node-v6.tar.gz -C /tmp/node/ --strip-components 1
	
	mkdir -p $(peldir)/bin/
	mv /tmp/node/bin/* $(peldir)/bin/
	
	mkdir -p $(peldir)/include/
	mv /tmp/node/include/* $(peldir)/include/
	
	mkdir -p $(peldir)/lib/
	mv /tmp/node/lib/* $(peldir)/lib/
	
	mkdir -p $(peldir)/share/doc/
	mv /tmp/node/share/doc/* $(peldir)/share/doc/
	
	mkdir -p $(peldir)/share/man/man1/
	mv /tmp/node/share/man/man1/* $(peldir)/share/man/man1/
	
	npm config set prefix $(peldir)



$(peldir)/elasticsearch/bin/elasticsearch:
	wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.6/elasticsearch-2.4.6.tar.gz -P /tmp/
	mkdir -p $(peldir)/elasticsearch
	tar -xzvf /tmp/elasticsearch-2.4.6.tar.gz -C $(peldir)/elasticsearch --strip-components 1
	echo 'export PATH=$(peldir)/elasticsearch/bin:$$PATH' >> .envrc
	echo 'export ES_HEAP_SIZE=100g' >> .envrc
	direnv allow
	
	mkdir -p $(datadir)/elasticsearch/logs
	sed -i "s@# cluster.name: my-application@cluster.name: pelias@g" $(peldir)/elasticsearch/config/elasticsearch.yml
	sed -i "s@# path.data: /path/to/data@path.data: $(datadir)/elasticsearch@g" $(peldir)/elasticsearch/config/elasticsearch.yml
	sed -i "s@# path.logs: /path/to/logs@path.logs: $(datadir)/elasticsearch/logs@g" $(peldir)/elasticsearch/config/elasticsearch.yml


