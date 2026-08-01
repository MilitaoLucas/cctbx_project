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
