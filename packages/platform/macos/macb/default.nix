{
  stdenv,
  lib,
  fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "macb";
  version = "unstable-20201214";

  src = fetchFromGitHub {
    owner = "aksommerville";
    repo = "macb";
    rev = "master";
    hash = "sha256-IKS/rLN1vRbOpZWZ1Bz1hWDYUlHhisiaN3C+Rc60Kdg=";
  };

  installPhase = ''
    mkdir -p $out/bin
    make install SUDO= INSTALLDST=$out/bin/macb
  '';
}
