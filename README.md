
# svg topo helper

This is a Makefile for helping out with generating svg contour maps.

## Requirements

You'll need a few tools installed, and the others will be installed on-demand by
the makefile:

* gdal - can be installed via homebrew
* npm
* vpype - for producing gcode

Producing gcode will automatically download and install arc-welder locally, as
the resulting gcode has an awful lot of straight line segments that form curves
in the output.

## Usage

Modify the `regions.mk` file according to the comments to define new regions,
then use `make <region>` to produce svg and gcode from it. If you'd like to only
produce one of those outputs, you can use the `<region.svg` or `<region>.gcode`
targets directly.

## References

* https://www.jamesrcroft.com/2018/02/svg-contour-maps/
