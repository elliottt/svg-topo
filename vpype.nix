{ pkgs ? import <nixpkgs> {} }:

# NOTE: I'm not using this, as the build time is massive, and i'm unsure how to
# get the gcode plugin included.

let
  poetry2nix = pkgs.poetry2nix;
in
  poetry2nix.mkPoetryApplication {
    projectDir = pkgs.fetchFromGitHub {
      owner = "abey79";
      repo = "vpype";
      rev = "1.13.0";
      sha256 = "1wlx24miyz20cb50bpd6hdq3s02cpwckn7njqjqarq7nm4k7y8qy";
    };

    # Skip extras, as that will cause opengl builds to happen.
    extras = [];

    overrides = poetry2nix.overrides.withDefaults (self: super:{
      altgraph = super.altgraph.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ super.setuptools ];
      });
      pnoise = super.pnoise.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ super.setuptools ];
      });
      pyinstaller-hooks-contrib = super.pyinstaller-hooks-contrib.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ super.setuptools ];
      });
      svgelements = super.svgelements.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ super.setuptools ];
      });
      pyinstaller = super.pyinstaller.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ pkgs.zlib ];
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.zlib ];
      });
    });
  }
