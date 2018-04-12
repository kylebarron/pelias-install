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

pelias: $(PELIAS_DEPS)
	@ echo "Done"

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


