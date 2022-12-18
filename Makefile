
.PHONY: all
all::

node_modules: package.json
	npm install

arc_welder:
	mkdir $@
	cd $@ && \
		wget https://github.com/FormerLurker/ArcWelderLib/releases/download/1.2.0/Linux.zip && \
		unzip Linux.zip

elevation.xml:
	wget https://gist.githubusercontent.com/crofty/eee53338259b1399b38022ec63f001a4/raw/de5dd0da82de27d63415d4d405acdfa853734399/elevation.xml

define region

$1.tif: elevation.xml
	gdal_translate \
	  -of GTiff \
	  -projwin $3 $4 $5 $6 \
	  -projwin_srs EPSG:4326 $$< $$@

$1-contour.geojson: INTERVAL=$2

$1.gcode: $1-contour-welded.gcode
	cp $$< $$@

.PHONY: $1
$1: $1-contour.svg $1.gcode

all:: $1

endef

$(eval $(call region,sedona,10,-111.8079103566,34.8342684252,-111.7841781713,34.8094661179))
$(eval $(call region,elden,25,-111.662406715,35.2961095392,-111.5710828624,35.2012021915))
$(eval $(call region,hart,25,-111.8000362239,35.3895397366,-111.6750667415,35.2634917447))

WIDTH ?= 700
HEIGHT ?= 1000
SCALE ?= 0.66

%-shaded.tif: %.tif
	gdaldem hillshade -az 75 -z 8 $< $@

%-4326.tif: %.tif
	gdalwarp -s_srs EPSG:3857 -t_srs EPSG:4326 $< $@

%-contour.geojson: %-4326.tif
	gdal_contour -a elev -i $(INTERVAL) -f GeoJSON $< $@

%-contour-resized.geojson: %-contour.geojson | node_modules
	npm exec geoproject -- \
		'd3.geoMercator().fitSize([$(WIDTH), $(HEIGHT)], d)' \
		--out $@ < $<

%-contour.svg: %-contour-resized.geojson | node_modules
	npm exec geo2svg -- -w $(WIDTH) -h $(HEIGHT) -o $@ < $<

%-contour.gcode: %-contour.svg vpype.toml | arc_welder
	vpype --config vpype.toml \
		read $< \
		linesort \
		linemerge \
		scale -o 0 0 $(SCALE) $(SCALE) \
		gwrite -p plotter $@
	arc_welder/bin/ArcWelder $@ $@

%-welded.gcode: %.gcode
	arc_welder/bin/ArcWelder $< $@

clean:
	$(RM) *.tif *.svg *.geojson

distclean: clean
	$(RM) elevation.xml
	$(RM) -r node_modules
	$(RM) -r gdalwmscache
	$(RM) -r arc_welder
