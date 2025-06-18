{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "cryanc";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "classilla";
    repo = pname;
    rev = version;
    hash = "sha256-eFMQYQGYGkVQAVz3V41Xm238TNqyQqY4gDYEaFLJuD8=";
  };

  NIX_CFLAGS_COMPILE = lib.optionalString (stdenv.hostPlatform ? retro68) "-Dusleep=sqrt";

  buildPhase = ''
    if ! $CC -E -o /dev/null - <<< "#include <arpa/inet.h>"
    then
      cp -r ${./.}/arpa .
    fi

    $CC -c cryanc.c -o cryanc.o
  '';

  installPhase = ''
    mkdir -p $out/lib $out/include
    cp -r cryanc.h $out/include/


    if ! $CC -E -o /dev/null - <<< "#include <arpa/inet.h>"
    then
      cp -r ${./.}/arpa $out/include/
    fi
    $AR rcs $out/lib/libcryanc.a cryanc.o
  '';
}
