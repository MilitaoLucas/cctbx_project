# Nix Packaging Progress

## Objective

Package CCTBX, SMTBX, and their native Python extensions for Python 3.13 with Nix, while preserving the upstream LibTBX runtime environment and supporting installed consumers.

## Packaging Changes

- Added the CCTBX Python package to the flake and Python package overlay.
- Added CMake-based native library and Boost.Python extension targets.
- Added the core CCTBX, SCITBX, and SMTBX libraries needed by the Python modules.
- Added CCTBX Miller extensions, including `cctbx_miller_ext`.
- Added asymmetric-map support, including `cctbx_asymmetric_map_ext` and its XPLOR map writer dependency.
- Added the direct-space ASU sources and `cctbx_sgtbx_asu_ext`.
- Added the CCTBX eltbx extension family, including `cctbx_eltbx_neutron_ext`.
- Added additional CCTBX extensions:
  - `cctbx_emma_ext`
  - `cctbx_orientation_ext`
  - `cctbx_french_wilson_ext`
  - `cctbx_anharmonic_ext`
  - `cctbx_merging_ext`
  - `cctbx_multipolar_ext`
  - `cctbx_other_restraints_ext`
  - `cctbx_adp_restraints_ext`
  - `cctbx_geometry_restraints_ext`
  - `cctbx_translation_search_ext`
- Added the required ASU and Boost.Python support dependencies.
- Added a fallback implementation for the Sasaki eltbx extension where the upstream symbol is unavailable.
- Added the remaining SCITBX extension family:
  - `scitbx_lbfgs_ext`, `scitbx_lbfgsb_ext`, `scitbx_lstbx_normal_equations_ext`
  - `scitbx_minpack_ext` and its native `libscitbx_minpack` library
  - `scitbx_r3_utils_ext`, `scitbx_iso_surface_ext`, `scitbx_rigid_body_ext`
  - `scitbx_wigner_ext`, `scitbx_graphics_utils_ext`
  - `scitbx_suffixtree_shared_ext`, `scitbx_suffixtree_single_ext`
- Added the bootstrap `fast_linalg_ext` and Boost.AdaptBX extensions:
  - `fast_linalg_ext` plus its native `libfast_linalg` library
  - `boost_adaptbx_python_streambuf_test_ext`
  - the `boost_adaptbx_graph_*` family (graph, connected component, BFS,
    graph structure comparison, maximum clique, min cut / max flow, utility,
    metric, clustering)
- Added extra CCTBX / OMPTBX / CMA-ES extensions:
  - `cctbx_dmtbx_ext`, `cctbx_large_scale_merging_ext`, `cctbx_maptbx_bcr_bcr_ext`
  - `cctbx_masks_ext`, `cctbx_symmetry_search_ext`, `determine_unit_cell_ext`
  - `omptbx_ext` plus its native `libomptbx` library, `cma_es_ext`
- Added the IOTBX extensions and their native libraries:
  - `iotbx_detectors_ext`, `iotbx_dsn6_map_ext`, `iotbx_shelx_ext`
  - `iotbx_wildcard_ext`
  - `iotbx_pdb_ext`, `iotbx_pdb_hierarchy_ext` plus native `libiotbx_pdb`
  - `iotbx_xplor_ext` plus native `libiotbx_xplor`
  - `mmtbx_reference_coordinate_ext`, `smtbx_ab_initio_ext`
  - Added a generated `smtbx/boost_python/flex_fwd.h` header.
- Added the `ccp4io` library as an external flake input and built it with Nix.
  - Uses older language standards (`-std=gnu90`, `gfortran -std=legacy`) so the
    vendored code builds unmodified rather than being patched.
  - Enabled the ccp4io-dependent extensions via `CCTBX_USE_CCP4IO`:
    `iotbx_mtz_ext` + native `libiotbx_mtz`, and `iotbx_ccp4_map_ext`.

## LibTBX Environment

- The package now generates and installs a relocatable LibTBX environment at:

  ```text
  $out/share/cctbx/libtbx_env
  ```

- The installed package updates LibTBX's installed-path handling so Python consumers can locate the packaged environment.
- Package configuration creates a temporary `future` compatibility module because LibTBX bootstrap checks for it and it is not available for Python 3.13 in nixpkgs.
- Consumer checks set `LIBTBX_BUILD` to the installed `share/cctbx` directory so `libtbx.load_env` can locate the environment outside a Conda installation.

## Rebuild Fix

The original `nix develop --expr` consumer test passed the flake package expression directly to `python.withPackages`. With a dirty source tree, that caused Nix to evaluate a different source snapshot and rebuild CCTBX.

The fix is implemented as the flake check `cctbx-consumer-imports` in `flake.nix`:

- It depends directly on `self.packages.${system}.cctbx`.
- It tests the realized package output rather than using the source tree as a new package input.
- It sets `PYTHONPATH` to the package's installed Python modules.
- It sets `LD_LIBRARY_PATH` to the package's libraries.
- It sets `LIBTBX_BUILD` to the installed LibTBX environment.

Run it with:

```sh
nix build .#checks.x86_64-linux.cctbx-consumer-imports
```

## Consumer Import Test

The check currently validates:

```python
import boost_optional_ext
import cctbx_eltbx_neutron_ext
import cctbx_asymmetric_map_ext
import cctbx.miller
```

The check succeeds with:

```text
consumer imports ok
```

## Build Configuration

- Uses `pkgs.ccacheStdenv` for the CCTBX Python package.
- Uses the shared ccache directory:

  ```text
  /var/cache/ccache
  ```

- Sets `CCACHE_NOHASHDIR=1` and `CCACHE_UMASK=007`.
- Excludes generated consumer artifacts such as `cctbx_example/` and `result` from the Nix source filter.

## Verification Completed

The following checks have passed:

```sh
nix build .#cctbx --print-build-logs
nix build .#checks.x86_64-linux.cctbx-consumer-imports --print-build-logs
nix build .#checks.x86_64-linux.cctbx-consumer-imports --no-link --print-build-logs
nix flake check --no-build
```

The second consumer-check build reused the existing derivation and did not rebuild CCTBX.

## Existing Commits

- `ac3e8bbec0` Add SMTBX consumer extension support
- `ce41710fc7` Install a relocatable libtbx environment
- `04aa25a7f3` Add cctbx miller extensions
- `b3f1dc2ecf` Complete asymmetric map dependencies

## Remaining Work

- `ccp4io_adaptbx_ext` is now built as a separate CMake+Nix package
  (`nix/ccp4io-adaptbx.nix`) that links the vendored CCP4/MMDB/SSM sources
  from the `ccp4io` and `ccp4io_adaptbx` flake inputs.
- Nothing else remains: `iotbx_cif_ext` (via in-repo `ucif`), `iotbx_dtrek_ext`,
  `iotbx_scalepack_ext`, and `boost_adaptbx_boost_thread_test_ext` are now built
  and imported by the install check.
- Decide whether the current uncommitted CMake, Nix, and flake changes should
  be split into additional focused commits.
