{ pkgs
, src ? ../.
, ccp4io ? null
}:

let
  inherit (pkgs) lib;
  pythonPackages = pkgs.python313Packages;
  generatorPython = pythonPackages.python.withPackages (ps: [ ps.six ps.pip ]);
  pythonBoost = pythonPackages.boost.override {
    enableNumpy = true;
  };
in
(pythonPackages.buildPythonPackage.override { stdenv = pkgs.ccacheStdenv; }) {
  pname = "cctbx";
  version = "unstable-2026-08-01";

  src = lib.cleanSourceWith {
    inherit src;
    filter = path: type:
      let pathString = toString path;
      in lib.cleanSourceFilter path type
        && pathString != "${toString src}/cctbx_example"
        && !(lib.hasPrefix "${toString src}/cctbx_example/" pathString)
        && pathString != "${toString src}/result";
  };
  format = "other";
  dontUsePythonBuild = true;
  dontUsePythonInstall = true;

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    generatorPython
  ];

  buildInputs = [
    pkgs.boost
    pythonBoost
    pkgs.eigen
    pkgs.zlib
  ] ++ lib.optional (ccp4io != null) ccp4io;

  dependencies = [
    pythonPackages.numpy
    pythonPackages.setuptools
    pythonPackages.six
  ];

  cmakeFlags = [
    "-DCCTBX_BUILD_PYTHON=ON"
    "-DCCTBX_BUILD_TESTS=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCCTBX_USE_CCP4IO=${if ccp4io != null then "ON" else "OFF"}"
  ] ++ (if ccp4io != null then [
    "-DCMAKE_INCLUDE_PATH=${ccp4io}/include"
    "-DCMAKE_LIBRARY_PATH=${ccp4io}/lib"
  ] else []);


  preConfigure = ''
    export CCACHE_DIR="/var/cache/ccache"
    export CCACHE_NOHASHDIR=1
    export CCACHE_UMASK=007

    # LibTBX's bootstrap still checks for the deprecated `future` package.
    # The package is not available for Python 3.13 in nixpkgs, but configure
    # only needs its import-time marker during environment generation.
    mkdir -p "$TMPDIR/future"
    printf '__version__ = "0"\n' > "$TMPDIR/future/__init__.py"
    export PYTHONPATH="$TMPDIR:${generatorPython}/lib/python3.13/site-packages''${PYTHONPATH:+:$PYTHONPATH}"

    rm -rf "$TMPDIR/libtbx-build"
    mkdir -p "$TMPDIR/libtbx-build"
    (
      cd "$TMPDIR/libtbx-build"
      "${pythonPackages.python.interpreter}" "${src}/libtbx/configure.py" \
        --current_working_directory "$TMPDIR/libtbx-build" \
        --no_bin_python \
        -r "${src}" cctbx smtbx
    )
  '';

  postInstall = ''
    install -d "$out/bin"
    install -d "$out/share/cctbx"
    export LIBTBX_BUILD="$TMPDIR/libtbx-build"
    export PREFIX="$out"
    export PYTHONPATH="$out/lib/python3.13/site-packages:${generatorPython}/lib/python3.13/site-packages"
    "${pythonPackages.python.interpreter}" - <<'PY'
import os
import shutil

from libtbx import env_config

default_dir = os.path.join(os.environ["PREFIX"], "share", "cctbx")
shutil.copy(
  os.path.join(os.environ["LIBTBX_BUILD"], "libtbx_env"),
  os.path.join(default_dir, "libtbx_env"),
)

# Nix keeps the Python interpreter and package prefix separate.
env_config.get_installed_path = lambda: default_dir

import libtbx.load_env
def skip_command_line_directories(self):
  pass
for module in libtbx.env.module_list:
  type(module).process_command_line_directories = skip_command_line_directories

from libtbx.auto_build.conda_build import update_libtbx_env
update_libtbx_env.update_libtbx_env(default_dir=default_dir)
PY
  '';

  doCheck = false;
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test -s "$out/lib/libcctbx.so"
    test -s "$out/lib/libscitbx_slatec.so"
    test -s "$out/lib/libscitbx_minpack.so"
    ${pythonPackages.python.interpreter} -c '
      import boost_python_meta_ext
      import boost_optional_ext
      import boost_tuple_ext
      import std_pair_ext
      import boost_rational_ext
      import scitbx_stl_set_ext
      import scitbx_stl_vector_ext
      import scitbx_stl_map_ext
      import scitbx_array_family_shared_ext
      import scitbx_linalg_ext
      import scitbx_array_family_flex_ext
       import cctbx_array_family_flex_ext
       import cctbx_statistics_ext
       import cctbx_emma_ext
       import cctbx_orientation_ext
       import cctbx_french_wilson_ext
       import cctbx_eltbx_chemical_elements_ext
       import cctbx_eltbx_henke_ext
       import cctbx_eltbx_fp_fdp_ext
       import cctbx_eltbx_icsd_radii_ext
       import cctbx_eltbx_neutron_ext
       import cctbx_eltbx_sasaki_ext
       import cctbx_eltbx_tiny_pse_ext
       import cctbx_eltbx_wavelengths_ext
       import cctbx_eltbx_covalent_radii_ext
       import cctbx_eltbx_attenuation_coefficient_ext
       import cctbx_sgtbx_asu_ext
       import cctbx_anharmonic_ext
       import cctbx_merging_ext
       import cctbx_multipolar_ext
       import cctbx_other_restraints_ext
       import cctbx_adp_restraints_ext
       import cctbx_geometry_restraints_ext
       import cctbx_translation_search_ext
       import cctbx_asymmetric_map_ext
       import cctbx_miller_ext
       import cctbx_xray_ext
       import cctbx_xray_observations_ext
       import cctbx_eltbx_xray_scattering_ext
       import cctbx_adptbx_ext
       import cctbx_uctbx_ext
       import cctbx_sgtbx_ext
       import cctbx_maptbx_ext
       import cctbx_crystal_ext
       import cctbx_covariance_ext
       import cctbx_geometry_ext
       import scitbx_cubicle_neighbors_ext
       import scitbx_fftpack_ext
       import cctbx_math_ext
      import scitbx_math_ext
       import scitbx_random_ext
       import scitbx_sparse_ext
       import scitbx_lbfgs_ext
       import scitbx_lbfgsb_ext
       import scitbx_lstbx_normal_equations_ext
       import scitbx_minpack_ext
       import scitbx_r3_utils_ext
       import scitbx_iso_surface_ext
       import scitbx_rigid_body_ext
       import scitbx_wigner_ext
       import scitbx_graphics_utils_ext
       import scitbx_suffixtree_shared_ext
       import scitbx_suffixtree_single_ext
       import scitbx_examples_bevington_ext
       import fast_linalg_ext
       import boost_adaptbx_python_streambuf_test_ext
       import boost_adaptbx_graph_ext
       import boost_adaptbx_graph_connected_component_algorithm_ext
       import boost_adaptbx_graph_breadth_first_search_ext
       import boost_adaptbx_graph_graph_structure_comparison_ext
       import boost_adaptbx_graph_maximum_clique_ext
       import boost_adaptbx_graph_min_cut_max_flow_ext
       import boost_adaptbx_graph_utility_ext
       import boost_adaptbx_graph_metric_ext
       import boost_adaptbx_graph_clustering_algorithm_ext
       import cctbx_dmtbx_ext
       import cctbx_large_scale_merging_ext
       import cctbx_maptbx_bcr_bcr_ext
       import cctbx_masks_ext
       import cctbx_symmetry_search_ext
       import cma_es_ext
       import determine_unit_cell_ext
       import iotbx_detectors_ext
       import iotbx_dsn6_map_ext
       import iotbx_pdb_ext
       import iotbx_pdb_hierarchy_ext
       import iotbx_shelx_ext
       import iotbx_wildcard_ext
       import iotbx_xplor_ext
       import iotbx_dtrek_ext
       import iotbx_scalepack_ext
       import iotbx_cif_ext
       import boost_adaptbx_boost_thread_test_ext
       import mmtbx_reference_coordinate_ext
       import omptbx_ext
       import smtbx_ab_initio_ext
       import iotbx_mtz_ext
       import iotbx_ccp4_map_ext
       import smtbx_array_family_ext
       import smtbx_stl_map_ext
       import smtbx_refinement_constraints_ext
       import smtbx_refinement_restraints_ext
       import smtbx_ed_data_ext
       import smtbx_refinement_least_squares_ext
       import smtbx_structure_factors_direct_ext
     '
    runHook postInstallCheck
  '';

  meta = {
    description = "Computational crystallography toolkit for Python 3.13";
    homepage = "https://github.com/cctbx/cctbx_project";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
