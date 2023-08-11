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

  shellHook = ''
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib"
  '';
}
