{
  description = "Development environment for elliottt/svg-topo";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        ArcWelder = pkgs.stdenv.mkDerivation rec {
          name = "ArcWelder";
          version = "1.2.0";
          src = pkgs.fetchFromGitHub {
            owner = "FormerLurker";
            repo = "ArcWelderLib";
            rev = version;
            sha256 = "sha256-FX05hqoHMUI5rrJFpspK6k2Edw2tBqRnbiQJFKftQkM=";
          };

          nativeBuildInputs = [
            pkgs.python3
            pkgs.clang
            pkgs.cmake
          ];

          enableParallelBuilding = true;

          doCheck = false;
        };

      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.gnumake
            pkgs.unzip
            pkgs.gdal
            pkgs.nodejs_20
            pkgs.python3
            pkgs.pipx

            ArcWelder
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ];
        };
      }
    );
}
