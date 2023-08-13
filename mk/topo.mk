
pipx:
	PIPX_HOME=pipx PIPX_BIN_DIR=pipx/bin pipx install vpype
	PIPX_HOME=pipx PIPX_BIN_DIR=pipx/bin pipx inject vpype vpype-gcode

node_modules: package.json
	npm install

arc_welder:
	mkdir $@
	cd $@ && \
		wget https://github.com/FormerLurker/ArcWelderLib/releases/download/1.2.0/Linux.zip && \
		unzip Linux.zip

elevation.xml:
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

%-contour.gcode: %-contour.svg vpype.toml | pipx
	./pipx/bin/vpype --config vpype.toml \
		read $< \
		linesort \
		linemerge \
		gwrite -p plotter $@

%-welded.gcode: %.gcode
	arc_welder/bin/ArcWelder $< $@

clean:
	$(RM) *.tif *.svg *.geojson *.gcode

distclean: clean
	$(RM) elevation.xml
	$(RM) -r node_modules
	$(RM) -r gdalwmscache
	$(RM) -r arc_welder
	$(RM) -r pipx
