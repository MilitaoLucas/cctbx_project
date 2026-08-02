{ pkgs
, src ? ../.
}:

let
  inherit (pkgs) lib;
  pythonPackages = pkgs.python313Packages;
  generatorPython = pythonPackages.python.withPackages (ps: [ ps.six ps.pip ]);
  pythonBoost = pythonPackages.boost.override {
    enableNumpy = true;
  };
in
pythonPackages.buildPythonPackage {
  pname = "cctbx";
  version = "unstable-2026-08-01";

  inherit src;
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
  ];

  dependencies = [
    pythonPackages.numpy
    pythonPackages.setuptools
    pythonPackages.six
  ];

  cmakeFlags = [
    "-DCCTBX_BUILD_PYTHON=ON"
    "-DCCTBX_BUILD_TESTS=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  preConfigure = ''
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
       import cctbx_asymmetric_map_ext
       import cctbx_miller_ext
       import cctbx_xray_ext
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
