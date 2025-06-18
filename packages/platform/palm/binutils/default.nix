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

  outputs = [ "out" "dev" ];

  buildInputs = [
    flex
    bison
  ];

  configureFlags = [
    "--target=${stdenv.targetPlatform.config}"
    "--disable-doc"
    "--enable-bfd"
  ];

  postInstall = ''
    mkdir -p $dev
    cp -r include $dev/include
  '';

  enableParallelBuilding = true;
}
