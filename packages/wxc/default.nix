{
  lib,
  stdenv,
  fetchFromGitea,
  wxWidgets,
  buildPackages,
}:

let
  nil = buildPackages.writeShellScript "nil" ''
    true
  '';
in stdenv.mkDerivation rec {
  pname = "wxc";
  version = "0.11.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wxHaskell";
    repo = "wxHaskell";
    rev = version;
    hash = "sha256-FQNOcZhKCSzIBQRt8CUZBvVB0OonrjiSUC1DWcam+O8=";
  };

  patches = [
    ./0000-fix-stc-return-types.patch
  ];

  buildInputs = [
    wxWidgets
  ];

  hardeningDisable = [ "all" ];

  configurePhase = ''
    PATH=${wxWidgets}/bin:$PATH ./configure --prefix=$out --hc=${nil} --hcpkg=${nil}
  '';

  buildPhase = ''
    make wxc-bindist
  '';
}
