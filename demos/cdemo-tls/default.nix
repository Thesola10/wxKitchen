{
  stdenv,
  lib,
  buildWxApp,
  wxWidgets,
  cryanc,
  curling
}:

let
  exe = stdenv.hostPlatform.extensions.executable;
in buildWxApp {
  withWxc = true;

  pname = "wxKitchen-C-demo";
  version = "0.0.0";

  src = ./.;

  buildInputs = [
    cryanc
    curling
  ];

  withConsoleMacOS = true;
  reservedMemoryMacOS = 7680;

  extraCFlags = "-I${cryanc}/include -I${curling}/include";
  extraLDFlags = "-L${curling} -lcurling -L${cryanc}/lib -lcryanc";

  buildPhase = ''
    mkdir -p $out/bin
    ${lib.optionalString stdenv.hostPlatform.isWindows "$WINDRES -I${wxWidgets}/include -O coff -o demo.res win32/demo.rc"}
    $CC demo.c ${lib.optionalString stdenv.hostPlatform.isWindows "demo.res"} \
      -o $out/bin/wxKitchenDemoC${exe}
  '';
}
