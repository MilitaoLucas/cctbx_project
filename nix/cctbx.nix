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
      import scitbx_math_ext
      import scitbx_random_ext
      import scitbx_sparse_ext
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
