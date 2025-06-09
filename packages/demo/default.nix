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
    $CXX $CXXFLAGS demo.cxx $LDFLAGS -o $out/bin/wxKitchenDemo${exe}
  '';
}
