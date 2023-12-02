
# svg topo helper

This is a Makefile for helping out with generating svg and gcode contour maps.

## Requirements

You'll need a few tools installed, and the others will be installed on-demand by
the makefile:

* gdal - can be installed via homebrew
* nodejs 20
* pipx
* unzip
* python3
* gnu make

If you're using nix, there's a `flake.nix` that replicates the environment
needed to produce maps, otherwise you'll need to ensure those dependencies are
present.

Producing gcode will automatically download and install arc-welder locally, as
the resulting gcode has an awful lot of straight line segments that form curves
in the output.

## Usage

The `projection.js` script creates a makefile that will produce svg and gcode
versions of a topographic map from the region specified, with the given contour
interval. Run:

```shell
$ node projection.js <region> <contour-interval> <lon> <lat> <width-km> <height-km> <out-width-mm>
```

To produce a makefile called `<region>.mk`. Then run:

```shell
$ make -f <region>.mk
```

to produce two files in the current directory named `<region>.svg` and
`<region>.gcode`.

## References

* https://www.jamesrcroft.com/2018/02/svg-contour-maps/
