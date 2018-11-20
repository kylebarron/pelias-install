# Notes:
# assumes direnv hook already exists

SHELL := /bin/bash
peldir := ${HOME}/local/pelias
node10_latest := $(shell curl -s https://nodejs.org/dist/latest-v10.x/ | grep -P 'linux-x64\.tar\.gz' | sed -n 1p | cut -d '"' -f 2)
direnv_latest := $(shell curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep 'browser_download_url' | grep 'linux-amd64' | cut -d '"' -f 4)
datadir := /disk/agebulk3/medicare.work/doyle-DUA51929/barronk-DUA51929/raw/pelias


PELIAS_DEPS := .envrc $(peldir)/bin/node
PELIAS_DEPS += $(peldir)/elasticsearch/bin/elasticsearch
PELIAS_DEPS += api schema whosonfirst openaddresses openstreetmap polylines interpolation
PELIAS_DEPS += $(HOME)/pelias.json
PELIAS_DEPS += .download_whosonfirst
PELIAS_DEPS += .download_openaddresses
PELIAS_DEPS += .download_openstreetmap
PELIAS_DEPS += .download_polylines

all: .pelias_finished_install

.pelias_finished_install: $(PELIAS_DEPS)
	touch .pelias_finished_install
	@ echo "Done"

api:
	rm -rf $(peldir)/api
	git clone git@github.com:pelias/api.git $(peldir)/api
	cd $(peldir)/api; \
	git checkout production; \
	echo 'export CC="gcc"' > .envrc; \
	echo 'export CXX="g++"' >> .envrc; \
	echo 'export CXXFLAGS=-I$$(pwd)/node_modules/node-postal/deps/include' >> .envrc; \
	echo 'export LDFLAGS=-L$$(pwd)/node_modules/node-postal/deps/lib' >> .envrc; \
	echo 'export LD_LIBRARY_PATH=$$(pwd)/node_modules/node-postal/deps/lib:$$LD_LIBRARY_PATH' >> .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	echo 'export PATH=$(peldir)/bin:$$PATH' >> .envrc; \
	echo 'export PATH=$(peldir)/elasticsearch/bin:$$PATH' >> .envrc; \
	echo 'export ES_HEAP_SIZE=100g' >> .envrc; \
	direnv allow; \
	npm install; \
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
	npm install;

schema:
	rm -rf $(peldir)/schema
	git clone git@github.com:pelias/schema.git $(peldir)/schema
	cd $(peldir)/schema; \
	git checkout production; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' > .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	direnv allow; \
	npm install;

whosonfirst:
	rm -rf $(peldir)/whosonfirst
	git clone git@github.com:pelias/whosonfirst.git $(peldir)/whosonfirst
	cd $(peldir)/whosonfirst; \
	git checkout production; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' > .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	direnv allow; \
	npm install;

openaddresses:
	rm -rf $(peldir)/openaddresses
	git clone git@github.com:pelias/openaddresses.git $(peldir)/openaddresses
	cd $(peldir)/openaddresses; \
	git checkout production; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' > .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	direnv allow; \
	npm install;

openstreetmap:
	rm -rf $(peldir)/openstreetmap
	git clone git@github.com:pelias/openstreetmap.git $(peldir)/openstreetmap
	cd $(peldir)/openstreetmap; \
	git checkout production; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' > .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	direnv allow; \
	npm install;

polylines:
	rm -rf $(peldir)/polylines
	git clone git@github.com:pelias/polylines.git $(peldir)/polylines
	cd $(peldir)/polylines; \
	git checkout production; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' > .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	direnv allow; \
	npm install;

interpolation: pbf2json
	rm -rf $(peldir)/interpolation
	git clone git@github.com:pelias/interpolation.git $(peldir)/interpolation
	cd $(peldir)/interpolation; \
	git checkout production; \
	echo 'export CC="gcc"' > .envrc; \
	echo 'export CXX="g++"' >> .envrc; \
	echo 'export CXXFLAGS=-I$$(pwd)/node_modules/node-postal/deps/include' >> .envrc; \
	echo 'export LDFLAGS=-L$$(pwd)/node_modules/node-postal/deps/lib' >> .envrc; \
	echo 'export LD_LIBRARY_PATH=$$(pwd)/node_modules/node-postal/deps/lib:$$LD_LIBRARY_PATH' >> .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' > .envrc; \
	echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> .envrc; \
	echo 'export PATH=$(peldir)/bin:$$PATH' >> .envrc; \
	echo 'export PATH=$(peldir)/elasticsearch/bin:$$PATH' >> .envrc; \
	echo 'export ES_HEAP_SIZE=100g' >> .envrc; \
	direnv allow; \
	npm install; \
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
	npm install;

pbf2json:
	rm -rf $(peldir)/pbf2json
	git clone git@github.com:pelias/pbf2json.git $(peldir)/pbf2json


$(HOME)/pelias.json:
	bash ./create_pelias_config.sh -d $(datadir)


.download_whosonfirst:
	cd $(peldir)/whosonfirst; \
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

.create_index:
	# Note: Install plugin before starting elasticsearch
	$(peldir)/elasticsearch/bin/plugin install analysis-icu
	# Now elasticsearch must be running
	cd $(peldir)/schema; node scripts/create_index.js
	touch .create_index

.import_openstreetmap:
	# Note, elasticsearch must be running already
	cd $(peldir)/openstreetmap; npm start
	touch .import_openstreetmap

.import_openaddresses:
	cd $(peldir)/openaddresses; npm start
	touch .import_openaddresses

.import_polylines:
	cd $(peldir)/polylines; npm start
	touch .import_polylines

.import_whosonfirst:
	cd $(peldir)/whosonfirst; npm start
	touch .import_whosonfirst

.envrc:
	mkdir -p $(peldir)/bin
	wget $(direnv_latest) -O $(peldir)/bin/direnv
	echo 'export PATH=$(peldir)/bin:$$PATH' > .envrc
	direnv allow


$(peldir)/bin/node:
	echo $(node10_latest)
	wget https://nodejs.org/dist/latest-v10.x/$(node10_latest) -O $(HOME)/tmp/node-v10.tar.gz

	mkdir -p $(HOME)/tmp/node
	tar -xzvf $(HOME)/tmp/node-v10.tar.gz -C $(HOME)/tmp/node/ --strip-components 1

	mkdir -p $(peldir)/bin/
	rsync $(HOME)/tmp/node/bin/ $(peldir)/bin/

	mkdir -p $(peldir)/include/
	rsync $(HOME)/tmp/node/include/ $(peldir)/include/

	mkdir -p $(peldir)/lib/
	rsync $(HOME)/tmp/node/lib/ $(peldir)/lib/

	mkdir -p $(peldir)/share/doc/
	rsync $(HOME)/tmp/node/share/doc/ $(peldir)/share/doc/

	mkdir -p $(peldir)/share/man/man1/
	rsync $(HOME)/tmp/node/share/man/man1/ $(peldir)/share/man/man1/

	npm config set prefix $(peldir)



$(peldir)/elasticsearch/bin/elasticsearch:
	wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.6/elasticsearch-2.4.6.tar.gz -P $(HOME)/tmp/
	mkdir -p $(peldir)/elasticsearch
	tar -xzvf $(HOME)/tmp/elasticsearch-2.4.6.tar.gz -C $(peldir)/elasticsearch --strip-components 1
	echo 'export PATH=$(peldir)/elasticsearch/bin:$$PATH' >> $(peldir)/.envrc
	echo 'export ES_HEAP_SIZE=100g' >> $(peldir)/.envrc
	cd $(peldir) && direnv allow

	mkdir -p $(datadir)/elasticsearch/logs
	sed -i "s@# cluster.name: my-application@cluster.name: pelias@g" $(peldir)/elasticsearch/config/elasticsearch.yml
	sed -i "s@# path.data: /path/to/data@path.data: $(datadir)/elasticsearch@g" $(peldir)/elasticsearch/config/elasticsearch.yml
	sed -i "s@# path.logs: /path/to/logs@path.logs: $(datadir)/elasticsearch/logs@g" $(peldir)/elasticsearch/config/elasticsearch.yml


