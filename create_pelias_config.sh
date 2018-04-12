#! /usr/bin/env bash
# Program: create_pelias_config.sh
# Author:  Kyle Barron <barronk@mit.edu>
# Purpose: Create ~/pelias.json
# Outputs: ~/pelias.json

while getopts ":d:p:" opt; do
  case $opt in
    d) datadir="$OPTARG"
    ;;
    p) p_out="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1
    ;;
  esac
done

echo "{}" \
  | jq '.elasticsearch.settings.index.number_of_replicas = 1' \
  | jq '.elasticsearch.settings.index.number_of_shards = 20' \
  | jq '.elasticsearch.settings.index.refresh_interval = "1m"' \
  | jq '.interpolation.client.adapter = "null"' \
  | jq '.imports.adminLookup.enabled = true' \
  | jq ".imports.openaddresses.datapath = \"$datadir/openaddresses\"" \
  | jq ".imports.openstreetmap.datapath = \"$datadir/openstreetmap\"" \
  | jq '.imports.openstreetmap.import[0] = "us-northeast-latest.osm.pbf"' \
  | jq '.imports.openstreetmap.import[1] = "us-midwest-latest.osm.pbf"' \
  | jq '.imports.openstreetmap.import[2] = "us-south-latest.osm.pbf"' \
  | jq '.imports.openstreetmap.import[3] = "us-west-latest.osm.pbf"' \
  | jq ".imports.polyline.datapath = \"$datadir/polyline\"" \
  | jq '.imports.polyline.files[0] = "us-midwest-latest.polylines"' \
  | jq ".imports.whosonfirst.datapath = \"$datadir/whosonfirst\"" \
  | jq '.imports.whosonfirst.importPostalcodes = true' \
  | jq '.imports.whosonfirst.importPlace = 85633793' \
  | jq ".imports.whosonfirst.importVenues = false" > $HOME/pelias.json
