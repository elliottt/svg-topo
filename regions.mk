
# The width in pixels of the resulting SVG image
WIDTH  ?= 700

# The height in pixels of the resulting SVG image
HEIGHT ?= 1000

# A scale multiplier to use when producing gcode of the contours.
SCALE  ?= 0.84

# Use the region macro to define rules for building maps of lat/lon regions.
#
# The format is:
#
# $1 - Name of the region
# $2 - Height interval in meters for contour lines
# $3 - Latitude of top-left corner
# $4 - Longitude of top-left corner
# $5 - Latitude of bottom-right corner
# $6 - Longitude of bottom-right corner
$(eval $(call region,sedona,18,-111.8079103566,34.8342684252,-111.7841781713,34.8094661179))
$(eval $(call region,elden,25,-111.662406715,35.2961095392,-111.5710828624,35.2012021915))
$(eval $(call region,hart,25,-111.8000362239,35.3895397366,-111.6750667415,35.2634917447))

