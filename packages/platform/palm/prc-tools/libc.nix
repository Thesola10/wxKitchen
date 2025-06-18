{
  stdenvNoLibs,
  lib,
  palm
}:

stdenvNoLibs.mkDerivation {
  inherit (palm.prc-tools) src version;

  pname = "prc-tools-libc";

  configureFlags = [
    "--enable-languages=c,c++"
  ];
}
