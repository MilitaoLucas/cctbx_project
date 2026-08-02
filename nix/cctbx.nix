{ pkgs
, src ? ../.
}:

let
  inherit (pkgs) lib;
  pythonPackages = pkgs.python313Packages;
  generatorPython = pythonPackages.python.withPackages (ps: [ ps.six ]);
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
    export PYTHONPATH="${generatorPython}/lib/python3.13/site-packages''${PYTHONPATH:+:$PYTHONPATH}"
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
