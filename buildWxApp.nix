{
  stdenv,
  lib,
  wxWidgets,
  wxc,
  libjpeg_original,
  libpng,
  zlib
}:

{
  withWxc ? false,
  ...
}@args:

stdenv.mkDerivation args // {
  hardeningDisable = [ "all" ];

  buildInputs = [
    wxWidgets
  ] ++ lib.optionals withWxc [
    wxc
  ] ++ args.buildInputs;

  preConfigure = ''
    export CFLAGS="$(${wxWidgets}/bin/wx-config --cflags)"
    export CXXFLAGS="$(${wxWidgets}/bin/wx-config --cxxflags)"
    export LDFLAGS="$(${wxWidgets}/bin/wx-config --libs) -L${lib.getLib libjpeg_original}/lib -L${zlib}/lib"
  '';
}
