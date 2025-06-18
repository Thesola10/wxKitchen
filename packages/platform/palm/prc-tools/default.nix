{
  stdenv,
  lib,
  palm
}:

stdenv.mkDerivation rec {
  pname = "prc-tools";
  version = "2.3";

  src = "${palm.sources.prc-tools-remix}/${pname}-${version}";

  configureFlags = [
    "--enable-languages=c,c++"
    "--target=${stdenv.targetPlatform.config}"
  ];

  # Normally the compiler and binutils are built as part 
  preConfigure = ''
    rm binutils gcc
    mkdir binutils gcc
    ln -s ${palm.binutils_unwrapped.src}/include binutils/include
    ln -s ${palm.binutils_unwrapped.src}/bfd binutils/bfd
  '';

  buildPhase = ''
    make -C tools obj-res build-prc multigen stubgen palmdev-prep trapfilt
  '';
}
