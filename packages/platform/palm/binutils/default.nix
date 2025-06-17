{
  stdenv,
  lib,
  palm,
  flex,
  bison
}:

stdenv.mkDerivation rec {
  pname = "palmos-binutils-unwrapped";
  version = "2.14";
  src = "${palm.sources.prc-tools-remix}/binutils-${version}";

  buildInputs = [
    flex
    bison
  ];

  configureFlags = [
    "--target=${stdenv.targetPlatform.config}"
    "--disable-doc"
  ];

  enableParallelBuilding = true;
}
