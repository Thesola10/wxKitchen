{
  stdenv,
  lib,
  buildWxApp,
  wxWidgets
}:

let
  exe = stdenv.hostPlatform.extensions.executable;
in buildWxApp {
  withWxc = true;

  pname = "wxKitchen-C-demo";
  version = "0.0.0";

  src = ./.;

  buildPhase = ''
    mkdir -p $out/bin
    ${lib.optionalString stdenv.hostPlatform.isWindows "$WINDRES -I${wxWidgets}/include -O coff -o demo.res win32/demo.rc"}
    $CC demo.c ${lib.optionalString stdenv.hostPlatform.isWindows "demo.res"} \
      -o $out/bin/wxKitchenDemoC${exe}
  '';
}
