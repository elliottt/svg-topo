
node_modules: package.json
	npm install

elevation.xml:
	wget https://gist.githubusercontent.com/crofty/eee53338259b1399b38022ec63f001a4/raw/de5dd0da82de27d63415d4d405acdfa853734399/elevation.xml

sedona.tif: elevation.xml
	gdal_translate \
	  -of GTiff \
	  -projwin -111.8045048788 34.8261744768 -111.7832188681 34.8122931961 \
	  -projwin_srs EPSG:4326 $< $@

%-shaded.tif: %.tif
	gdaldem hillshade -az 75 -z 8 $< $@

%-4326.tif: %.tif
	gdalwarp -s_srs EPSG:3857 -t_srs EPSG:4326 $< $@

%-contour.geojson: %-4326.tif
	gdal_contour -a elev -i 10.0 -f GeoJSON $< $@

%-contour-resized.geojson: %-contour.geojson | node_modules
	npm exec geoproject -- \
		'd3.geoMercator().fitSize([1000, 1000], d)' \
		--out $@ < $<

%-contour.svg: %-contour-resized.geojson | node_modules
	npm exec geo2svg -- -w 1000 -h 1000 -o $@ < $<

clean:
	$(RM) *.tif *.svg *.geojson

distclean: clean
	$(RM) elevation.xml
	$(RM) -r node_modules
	$(RM) -r gdalwmscache
