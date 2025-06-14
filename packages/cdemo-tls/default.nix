{
  stdenv,
  lib,
  buildWxApp,
  wxWidgets,
  cryanc,
  GUSI
}:

let
  exe = stdenv.hostPlatform.extensions.executable;
in buildWxApp rec {
  withWxc = true;

  pname = "wxKitchen-C-demo";
  version = "0.0.0";

  src = ./.;

  buildInputs = [
    cryanc
  ] ++ lib.optionals (stdenv.hostPlatform ? retro68) [
    GUSI
  ];

  NIX_CFLAGS_COMPILE = "-I${cryanc}/include"
                     + lib.optionalString (stdenv.hostPlatform ? retro68) "-I${GUSI}/include";
  NIX_CFLAGS_LINK = "-L${cryanc}/lib -lcryanc "
                  + lib.optionalString (stdenv.hostPlatform ? retro68) "-L${GUSI}/lib -lGUSI";

  buildPhase = ''
    mkdir -p $out/bin
    ${lib.optionalString stdenv.hostPlatform.isWindows "$WINDRES -I${wxWidgets}/include -O coff -o demo.res win32/demo.rc"}
    $CC demo.c ${lib.optionalString stdenv.hostPlatform.isWindows "demo.res"} \
      -o $out/bin/wxKitchenDemoC${exe} ${NIX_CFLAGS_LINK}
  '';
}
