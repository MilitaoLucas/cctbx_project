{
  description = "Nix packaging for the Computational Crystallography Toolbox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ccp4io.url = "github:cctbx/ccp4io";
    ccp4io.flake = false;
    ccp4io_adaptbx.url = "github:cctbx/ccp4io_adaptbx";
    ccp4io_adaptbx.flake = false;
  };

  outputs =
    { self, nixpkgs, ccp4io, ccp4io_adaptbx }:
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
              ccp4io = self.packages.${final.system}.ccp4io;
            };
          })
        ];
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          ccp4io = import ./nix/ccp4io.nix {
            inherit pkgs;
            src = ccp4io;
          };
          cctbx = import ./nix/cctbx.nix {
            inherit pkgs;
            src = ./.;
            ccp4io = self.packages.${system}.ccp4io;
          };
          ccp4io-adaptbx = import ./nix/ccp4io-adaptbx.nix {
            inherit pkgs;
            ccp4io = ccp4io;
            ccp4io_adaptbx = ccp4io_adaptbx;
            cctbx = ./.;
          };
          cctbx-base = import ./nix/cctbx-base.nix {
            inherit pkgs;
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
            import cctbx_maptbx_bcr_bcr_ext
            import cctbx_masks_ext
            import cctbx_symmetry_search_ext
            import cctbx_dmtbx_ext
            import determine_unit_cell_ext
            import omptbx_ext
            import iotbx_detectors_ext
            import iotbx_dsn6_map_ext
            import iotbx_pdb_ext
            import iotbx_pdb_hierarchy_ext
            import iotbx_shelx_ext
            import iotbx_wildcard_ext
            import iotbx_xplor_ext
            import mmtbx_reference_coordinate_ext
            import smtbx_ab_initio_ext
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
