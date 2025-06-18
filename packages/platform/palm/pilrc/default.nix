{
  stdenv,
  lib,
  palm,
  automake,
  autoconf,
  fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "pilrc";
  version = "2.3.90";

  src = fetchFromGitHub {
    owner = "jichu4n";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Ns6ZXu7lVJ4CM0CFC4PJvaUuo4JpDKcRbGEzkkAt1TQ=";
  };

  nativeBuildInputs = [
    automake
    autoconf
  ];

  updateAutotoolsGnuConfigScriptsPhase = ''
    cd unix
    aclocal; automake --add-missing; autoconf
    cd ..
  '';

  configurePhase = ''
    ./unix/configure --prefix=$out --disable-pilrcui
  '';
}
