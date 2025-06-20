{
  stdenv,
  lib,
  gmp,
  mpfr,
  libmpc,
  palm
}:

stdenv.mkDerivation rec {
  pname = "palmos-gcc-unwrapped";
  version = "3.3.1";
  src = "${palm.sources.prc-tools-remix}/gcc-${version}";

  buildInputs = [
    palm.prc-tools
    palm.binutils_unwrapped
    gmp
    mpfr
    libmpc
  ];

  CFLAGS = "-I${palm.prc-tools.src}/include";

  configureFlags = [
    "--enable-targets=${stdenv.targetPlatform.config}"
    "--enable-languages=c,c++"
    "--with-palmdev-prefix=${palm.sdk}"
  ];

  hardeningDisable = [ "format" ];
  enableParallelBuilding = true;
}
