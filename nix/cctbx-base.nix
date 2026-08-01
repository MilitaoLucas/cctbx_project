{ pkgs
, src ? ../.
}:

let
  inherit (pkgs) lib;
  pythonBoost = pkgs.python313Packages.boost.override {
    enableNumpy = true;
    patches = [ ./boost-python-numpy2.patch ];
  };
  python = pkgs.python313.withPackages (ps: with ps; [
    numpy
    setuptools
    six
  ]);
in
pkgs.stdenv.mkDerivation {
  pname = "cctbx-base";
  version = "unstable-2026-08-01-cmake-python313";

  inherit src;
  strictDeps = true;

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    python
  ];

  buildInputs = [
    pkgs.boost
    pythonBoost
    pkgs.eigen
    pkgs.zlib
  ];

  cmakeFlags = [
    "-DCCTBX_BUILD_PYTHON=ON"
    "-DCCTBX_BUILD_TESTS=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test -s "$out/lib/libcctbx.so"
    test -s "$out/lib/libscitbx_slatec.so"
    ${python}/bin/python --version
    PYTHONPATH="$out/lib/python3.13/site-packages" \
      LD_LIBRARY_PATH="$out/lib" \
      ${python}/bin/python -c 'import boost_python_meta_ext, boost_optional_ext, scitbx_array_family_flex_ext, cctbx_array_family_flex_ext, cctbx_statistics_ext, scitbx_math_ext, scitbx_random_ext, scitbx_sparse_ext'
    runHook postInstallCheck
  '';

  meta = {
    description = "Computational crystallography toolkit built with CMake";
    homepage = "https://github.com/cctbx/cctbx_project";
    license = lib.licenses.bsd3;
    mainProgram = "cctbx.python";
    platforms = [ "x86_64-linux" ];
  };
}
