{
  description = "clay-zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs-unstable.zig_0_17
            pkgs.libx11
            pkgs.libxrandr
            pkgs.libxinerama
            pkgs.libxcursor
            pkgs.libxi
            pkgs.libGL
          ];

          env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.libglvnd
            pkgs.alsa-lib
          ];
        };
      }
    );
}
