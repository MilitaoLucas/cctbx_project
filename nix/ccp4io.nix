{ pkgs, src }:

pkgs.stdenv.mkDerivation {
  pname = "ccp4io";
  version = "6.4.0";

  inherit src;

  nativeBuildInputs = [
    pkgs.autoreconfHook
    pkgs.gfortran
    pkgs.libtool
  ];

  buildInputs = [
    pkgs.gfortran.cc
  ];

  # The flake input is a git checkout (not a tarball), so no extraction
  # happens in unpackPhase. `sourceRoot` must resolve inside the copied tree.
  sourceRoot = "source/libccp4";

  configureFlags = [
    "--enable-fortran"
  ];

  # ccp4io (2021) relies on K&R-style unprototyped declarations (e.g. putenv)
  # and F77-style implicit type mismatches. Use older language standards so it
  # builds unmodified instead of patching the sources.
  NIX_CFLAGS_COMPILE = "-std=gnu90 -D_DEFAULT_SOURCE";
  FFLAGS = "-std=legacy";
  FCFLAGS = "-std=legacy";

  meta = with pkgs.lib; {
    description = "CCP4 library for crystallographic file formats";
    homepage = "https://github.com/cctbx/ccp4io";
    license = licenses.lgpl3;
    platforms = platforms.linux;
  };
}
