{
  stdenv,
  lib,
  wxWidgets,
  cryanc
}:

stdenv.mkDerivation {
  name = "curling";

  src = ./.;

  buildInputs = [
    wxWidgets
    cryanc
  ];

  NIX_CFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/cc-cflags";
  NIX_CXXFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/libcxx-cxxflags";


  buildPhase = ''
    for file in *.cxx
    do
      $CXX -g -c $file -o $file.o
    done
  '';

  installPhase = ''
    mkdir -p $out/lib $out/include
    $AR rcs $out/lib/libcurling.a *.o
    cp curling.h $out/include/
  '';
}
