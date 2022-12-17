
.PHONY: all
all::

node_modules: package.json
	npm install

elevation.xml:
	wget https://gist.githubusercontent.com/crofty/eee53338259b1399b38022ec63f001a4/raw/de5dd0da82de27d63415d4d405acdfa853734399/elevation.xml

define region

$1.tif: elevation.xml
	gdal_translate \
	  -of GTiff \
	  -projwin $2 $3 $4 $5 \
	  -projwin_srs EPSG:4326 $$< $$@

all:: $1-contour.svg

endef

$(eval $(call region,sedona,-111.8045048788,34.8261744768,-111.7832188681,34.8122931961))
$(eval $(call region,elden,-111.642112,35.260701,-111.5913,35.227895))
$(eval $(call region,hart,-111.792175,35.376128,-111.712953,35.317111))

WIDTH ?= 1000
HEIGHT ?= 1000
SCALE ?= 0.66

%-shaded.tif: %.tif
	gdaldem hillshade -az 75 -z 8 $< $@

%-4326.tif: %.tif
	gdalwarp -s_srs EPSG:3857 -t_srs EPSG:4326 $< $@

%-contour.geojson: %-4326.tif
	gdal_contour -a elev -i 10.0 -f GeoJSON $< $@

%-contour-resized.geojson: %-contour.geojson | node_modules
	npm exec geoproject -- \
		'd3.geoMercator().fitSize([$(WIDTH), $(HEIGHT)], d)' \
		--out $@ < $<

%-contour.svg: %-contour-resized.geojson | node_modules
	npm exec geo2svg -- -w $(WIDTH) -h $(HEIGHT) -o $@ < $<

%-contour.gcode: %-contour.svg vpype.toml
	vpype --config vpype.toml \
		read $< \
		linesort \
		linemerge \
		scale -o 0 0 $(SCALE) $(SCALE) \
		gwrite -p plotter $@

clean:
	$(RM) *.tif *.svg *.geojson

distclean: clean
	$(RM) elevation.xml
	$(RM) -r node_modules
	$(RM) -r gdalwmscache
