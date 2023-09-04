{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = [
    pkgs.gnumake
    pkgs.unzip
    pkgs.gdal
    pkgs.nodejs_20
    pkgs.python3
    pkgs.pipx
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
  ];
}
