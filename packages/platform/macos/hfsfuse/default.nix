{
  stdenv,
  lib,
  fetchFromGitHub,
  fuse3,
  utf8proc,
  zlib,
  lzfse,
  libarchive
}:
stdenv.mkDerivation rec {
  pname = "hfsfuse";
  version = "0.292";

  buildInputs = [
    fuse3
    utf8proc
    zlib
    lzfse
    libarchive
  ];

  PREFIX = placeholder "out";

  src = fetchFromGitHub {
    owner = "0x09";
    repo = "hfsfuse";
    rev = version;
    hash = "sha256-nz6P1b8icDfL1aAZr8klQ7kD9Q8oddUZcJ5DbfY5V0w=";
  };
}


