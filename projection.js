
import * as fs from 'fs/promises';

function deg2rad(deg) {
  return (deg * Math.PI) / 180;
}

function rad2deg(rad) {
  return (rad * 180) / Math.PI;
}

async function main() {
  let args = process.argv.slice(2);

  if (args.length != 7) {
    console.error("Usage: node process.js region contour-meters lat-center lon-center width-km height-km width-mm");
    process.exit(1);
  }

  let [region, contour_meters, lng, lat, width, height, width_mm] = args;

  // TODO: assert bounds for lng and lat

  lng = deg2rad(lng);
  lat = deg2rad(lat);

  // Translated from https://stackoverflow.com/a/7110219
  const radius = 6371;
  const parallel_radius = radius * Math.cos(lat);

  // Average the difference between the two different latitude rings.
  const width_2 = width / (2 * parallel_radius);

  // The radius is consistent for distance along one of the rings of longitude.
  const height_2 = height / (2 * radius);

  const lng_min = rad2deg(lng - width_2);
  const lat_min = rad2deg(lat - height_2);
  const lng_max = rad2deg(lng + width_2);
  const lat_max = rad2deg(lat + height_2);

  // Okay, this is gross. Treat pixels and mm as the same thing for the purposes
  // of producing the initial svg, as vpype can make the conversion back to mm
  // when producing the gcode.
  let width_px = width_mm;
  let height_px = width_mm;

  if (width > height) {
    height_px = height_px * (height / width);
  } else if (height > width) {
    width_px = width_px * (width / height);
  }

  await fs.writeFile(`${region}.mk`, `
.PHONY: all
all: ${region}.svg ${region}-gcode.svg ${region}.gcode

WIDTH := ${width_px}
HEIGHT := ${height_px}
INTERVAL := ${contour_meters}

LAT_MIN := ${lat_min}
LAT_MAX := ${lat_max}

clean:
	$(RM) -r build/maps/${region}
	$(RM) -f ${region}.svg
	$(RM) -f ${region}.gcode

build/maps/${region}: | build/maps
	mkdir $@

build/maps/${region}/${region}.tif: build/elevation.xml | build/maps/${region}
	gdal_translate \\
	  -r average \\
	  -of GTiff \\
	  -outsize $(WIDTH) $(HEIGHT) \\
	  -projwin ${lng_min} ${lat_max} ${lng_max} ${lat_min} \\
	  -projwin_srs EPSG:4326 $< $@

build/maps/${region}/${region}-contour.geojson: 

${region}.gcode: build/maps/${region}/${region}-contour-welded.gcode
	cp $< $@

build/maps/${region}/${region}.svg: build/maps/${region}/${region}-contour.svg
	cp $< $@

${region}.svg: build/maps/${region}/${region}.svg
	cp $< $@

${region}-gcode.svg: build/maps/${region}/${region}-contour.gcode.svg
	cp $< $@

include mk/topo.mk

  `);
}

await main();
