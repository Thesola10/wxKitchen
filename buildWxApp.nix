{
  stdenv,
  lib,
  wxWidgets,
  wxc,
}:

{
  withWxc ? false,
  buildInputs ? [],
  ...
}@args:

stdenv.mkDerivation (args // {
  hardeningDisable = [ "all" ];

  buildInputs = [
    wxWidgets
  ] ++ lib.optionals withWxc [
    wxc
  ] ++ buildInputs;

  NIX_CFLAGS_COMPILE = (lib.readFile "${wxWidgets}/nix-support/cc-cflags")
                     + lib.optionalString withWxc "-I${wxc}/include -imacros ${wxWidgets}/include/wx/wx.h";
  NIX_CXXFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/libcxx-cxxflags";
  NIX_CFLAGS_LINK = (lib.readFile "${wxWidgets}/nix-support/cc-ldflags")
                  + lib.optionalString withWxc "-L${wxc}/lib -lwxc";
})
