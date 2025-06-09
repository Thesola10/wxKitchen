{
  stdenv,
  buildWxApp,
  wxWidgets,
  lib,
  zlib,
  libjpeg_original
}:

let
  exe = stdenv.hostPlatform.extensions.executable;
in buildWxApp {
  pname = "wxKitchen-demo";
  version = "0.0.0";

  src = ./.;

  buildPhase = ''
    export CFLAGS="$(${wxWidgets}/bin/wx-config --cflags)"
    export CXXFLAGS="$(${wxWidgets}/bin/wx-config --cxxflags)"
    export LDFLAGS="-L${lib.getLib libjpeg_original}/lib -L${zlib}/lib $(${wxWidgets}/bin/wx-config --libs)"
    mkdir -p $out/bin
    ${if stdenv.hostPlatform.isWindows then "$WINDRES -I${wxWidgets}/include -O coff -o demo.res win32/demo.rc" else ""}
    $CXX $CXXFLAGS demo.cxx ${if stdenv.hostPlatform.isWindows then "demo.res" else ""} \
      $LDFLAGS -o $out/bin/wxKitchenDemo${exe}
  '';
}
