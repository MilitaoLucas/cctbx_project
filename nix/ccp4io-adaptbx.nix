{ pkgs, ccp4io, ccp4io_adaptbx, cctbx }:

let
  inherit (pkgs) lib;
  python = pkgs.python313;
  pythonBoost = pkgs.python313Packages.boost.override {
    enableNumpy = true;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "ccp4io-adaptbx";
  version = "unstable-2024";

  # The CMake build is a self-contained project shipped here; the actual
  # vendored sources come from the ccp4io and ccp4io_adaptbx flake inputs.
  src = lib.cleanSource ./ccp4io_adaptbx;

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
  ];

  # The vendored CCP4 C code is old and trips modern glibc fortify /
  # format-overflow checks that are fatal under hardening. Relax them.
  NIX_HARDENING_ENABLE = "none";
  NIX_CFLAGS_COMPILE = "-Wno-error -Wno-format-overflow -Wno-format-security -Wno-implicit-function-declaration -Wno-incompatible-pointer-types";

  buildInputs = [
    python
    pythonBoost
    pkgs.boost
  ];

  # The vendored sources refer to the adaptbx tree as <ccp4io_adaptbx/...>.
  # Stage it under that name in the build so the includes resolve.
  preConfigure = ''
    mkdir -p ccp4io_adaptbx
    cp -rL ${ccp4io_adaptbx}/* ccp4io_adaptbx/
    # The adaptbx directory cannot be known at eval time, so append the flag
    # here for the configure step.
    cmakeFlagsArray+=("-DCCP4IO_ADAPTBX_SOURCE_DIR=$PWD/ccp4io_adaptbx")
  '';

  cmakeFlags = [
    "-DCCP4IO_SOURCE_DIR=${ccp4io}"
    "-DCCTBX_SOURCE_DIR=${cctbx}"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  postInstall = ''
    export PYTHONPATH="$out/lib/python3.13/site-packages"
    export LD_LIBRARY_PATH="$out/lib"
    ${python}/bin/python -c 'import ccp4io_adaptbx_ext; print("ccp4io_adaptbx_ext import ok")'
  '';

  meta = with pkgs.lib; {
    description = "CCP4 i/o Boost.Python extension for CCTBX";
    homepage = "https://github.com/cctbx/ccp4io_adaptbx";
    license = licenses.lgpl3;
    platforms = platforms.linux;
  };
}
