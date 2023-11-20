
build:
	mkdir $@

build/maps: | build
	mkdir $@

build/pipx: | build
	PIPX_HOME=$@ PIPX_BIN_DIR=build/pipx/bin pipx install vpype
	PIPX_HOME=$@ PIPX_BIN_DIR=build/pipx/bin pipx inject vpype vpype-gcode

node_modules: package.json
	npm install

build/arc_welder: | build
	mkdir $@
	cd $@ && \
		wget https://github.com/FormerLurker/ArcWelderLib/releases/download/1.2.0/Linux.zip && \
		unzip Linux.zip

build/elevation.xml: | build
	cd build && \
	  wget https://gist.githubusercontent.com/crofty/eee53338259b1399b38022ec63f001a4/raw/de5dd0da82de27d63415d4d405acdfa853734399/elevation.xml

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

%-contour.gcode: %-contour.svg vpype.toml | build/pipx
	./build/pipx/bin/vpype --config vpype.toml \
		read -m -l new $<  \
		linesort \
		linemerge \
		reloop \
		frame -l new \
		lswap 1 2 \
		frame -l new \
		propset -l 1 --type int strength 0 \
		propset -l 1 --type str stop "M0" \
		write $@.svg \
		gwrite -p plotter $@

# Awful hack to work around nix issues with the libc that gets patched in by
# shell.nix
%-welded.gcode: %.gcode | build/arc_welder
	LD_LIBRARY_PATH= ./build/arc_welder/bin/ArcWelder $< $@

distclean: clean
	$(RM) -rf build
	$(RM) -r node_modules
	$(RM) -r gdalwmscache
