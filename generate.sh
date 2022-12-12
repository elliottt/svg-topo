#!/usr/bin/env bash

set -euo pipefail

gdal_translate \
  -of GTiff \
  -projwin -111.8045048788 34.8261744768 -111.7832188681 34.8122931961 \
  -projwin_srs EPSG:4326 elevation.xml sedona.tif

gdaldem hillshade \
  -az 75 -z 8 -compute_edges \
  sedona.tif sedona-shaded.tif

gdalwarp \
  -s_srs EPSG:3857 \
  -s_srs EPSG:4326 \
  sedona.tif sedona-4326.tif

gdal_contour \
  -a elev \
  -i 10.0 \
  -f GeoJSON \
  sedona-4326.tif sedona.geojson

npm exec geoproject -- \
  'd3.geoMercator().fitSize([1000, 1000], d)' \
  --out sedona-resized.geojson \
  < sedona.geojson

npm exec geo2svg -- \
  -w 1000 \
  -h 1000 \
  -o sedona-contours.svg \
  < sedona-resized.geojson

cp sedona-shaded.tif "/mnt/c/Users/Trevor Elliott/Desktop/"
cp sedona-contours.svg "/mnt/c/Users/Trevor Elliott/Desktop/"
