{
  description = "Nix packaging for the Computational Crystallography Toolbox";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      overlays.default = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (pythonFinal: _pythonPrev: {
            cctbx = import ./nix/cctbx.nix {
              pkgs = final;
              src = ./.;
            };
          })
        ];
      };

      packages = forAllSystems (system: {
        cctbx = import ./nix/cctbx.nix {
          pkgs = import nixpkgs { inherit system; };
          src = ./.;
        };
        cctbx-base = import ./nix/cctbx-base.nix {
          pkgs = import nixpkgs { inherit system; };
          src = ./.;
        };
        default = self.packages.${system}.cctbx-base;
      });

      checks = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          python = pkgs.python313.withPackages (ps: [
            ps.numpy
            ps.setuptools
            ps.six
          ]);
          cctbx = self.packages.${system}.cctbx;
        in
        {
          cctbx-base = self.packages.${system}.cctbx-base;

          # Test the realized package output, not the flake source as a new
          # Python package input. This keeps the consumer check from causing
          # a second cctbx build when the source tree is dirty.
          cctbx-consumer-imports = pkgs.runCommand "cctbx-consumer-imports" {
            nativeBuildInputs = [ python ];
          } ''
            export PYTHONPATH="${cctbx}/lib/python3.13/site-packages"
            export LD_LIBRARY_PATH="${cctbx}/lib"
            export LIBTBX_BUILD="${cctbx}/share/cctbx"
            ${python}/bin/python -c '
            import boost_optional_ext
            import cctbx_eltbx_neutron_ext
            import cctbx_asymmetric_map_ext
            import scitbx_lbfgs_ext
            import scitbx_lbfgsb_ext
            import scitbx_minpack_ext
            import scitbx_lstbx_normal_equations_ext
            import cctbx.miller
            print("consumer imports ok")
            '
            touch "$out"
          '';
        });

      devShells = forAllSystems (system: {
        default =
          let
            pkgs = import nixpkgs { inherit system; };
            pythonBoost = pkgs.python313Packages.boost.override {
              enableNumpy = true;
            };
          in
          pkgs.mkShell {
            packages = [
              pkgs.cmake
              pkgs.boost
              pythonBoost
              pkgs.eigen
              (pkgs.python313.withPackages (ps: [
                ps.numpy
                ps.setuptools
                ps.six
              ]))
            ];
          };
      });
    };
}
