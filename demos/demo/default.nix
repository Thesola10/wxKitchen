{
  stdenv,
  buildWxApp,
  wxWidgets,
}:

let
  exe = stdenv.hostPlatform.extensions.executable;
in buildWxApp {
  pname = "wxKitchen-demo";
  version = "0.0.0";

  src = ./.;

  buildPhase = ''
    mkdir -p $out/bin
    ${if stdenv.hostPlatform.isWindows then "$WINDRES -I${wxWidgets}/include -O coff -o demo.res win32/demo.rc" else ""}
    $CXX demo.cxx ${if stdenv.hostPlatform.isWindows then "demo.res" else ""} \
      -o $out/bin/wxKitchenDemo${exe}
  '';
}
