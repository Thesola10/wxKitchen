{
  stdenv,
  lib,
  fetchFromGitHub,

  GUSI ? null
}:

stdenv.mkDerivation rec {
  pname = "cryanc";
  version = "2.2";

  NIX_CFLAGS_COMPILE = lib.optionalString (stdenv.hostPlatform ? retro68) "-I${GUSI}/include";

  propagatedBuildInputs = lib.optionals (stdenv.hostPlatform ? retro68) [
    GUSI
  ];

  src = fetchFromGitHub {
    owner = "classilla";
    repo = pname;
    rev = version;
    hash = "sha256-eFMQYQGYGkVQAVz3V41Xm238TNqyQqY4gDYEaFLJuD8=";
  };

  buildPhase = ''
    $CC -c cryanc.c -o cryanc.o
  '';

  installPhase = ''
    mkdir -p $out/lib $out/include
    cp cryanc.h $out/include/
    $AR rcs $out/lib/libcryanc.a cryanc.o
  '';
}
