
import * as fs from 'fs/promises';

function deg2rad(deg) {
  return (deg * Math.PI) / 180;
}

function rad2deg(rad) {
  return (rad * 180) / Math.PI;
}

async function main() {
  let args = process.argv.slice(2);

  if (args.length != 8) {
    console.error("Usage: node process.js region contour-meters lat-center lon-center width-km height-km width-px height-px");
    process.exit(1);
  }

  let [region, contour_meters, lng, lat, width, height, width_px, height_px] = args;

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

  await fs.writeFile(`${region}.mk`, `
.PHONY: all
all: ${region}.svg ${region}.gcode

${region}.tif: elevation.xml
	gdal_translate \\
	  -of GTiff \\
	  -projwin ${lng_min} ${lat_max} ${lng_max} ${lat_min} \\
	  -projwin_srs EPSG:4326 $< $@

${region}-contour.geojson: INTERVAL=${contour_meters}

${region}.gcode: ${region}-contour.gcode
	cp $< $@

${region}.svg: WIDTH=${width_px}
${region}.svg: HEIGHT=${height_px}
${region}.svg: ${region}-contour.svg
	cp $< $@

include mk/topo.mk

  `);
}

await main();
