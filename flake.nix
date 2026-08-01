{
  description = "Nix packaging for the Computational Crystallography Toolbox";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system: {
        cctbx-base = import ./nix/cctbx-base.nix {
          pkgs = import nixpkgs { inherit system; };
          src = ./.;
        };
        default = self.packages.${system}.cctbx-base;
      });

      checks = forAllSystems (system: {
        cctbx-base = self.packages.${system}.cctbx-base;
      });

      devShells = forAllSystems (system: {
        default = let
          pkgs = import nixpkgs { inherit system; };
          pythonBoost = pkgs.python313Packages.boost.override {
            enableNumpy = true;
            patches = [ ./nix/boost-python-numpy2.patch ];
          };
        in pkgs.mkShell {
          packages = [
            pkgs.cmake
            pkgs.boost
            pythonBoost
            pkgs.eigen
            (pkgs.python313.withPackages (ps: [ ps.numpy ps.setuptools ps.six ]))
          ];
        };
      });
    };
}
