{
  stdenv,
  buildWxApp,
  wxWidgets
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
    export LDFLAGS="$(${wxWidgets}/bin/wx-config --libs)"
    mkdir -p $out/bin
    $CXX $CXXFLAGS $LDFLAGS -o $out/bin/wxKitchenDemo${exe} demo.cxx
  '';
}
