{
  stdenv,
  lib,
  fetchurl,
  pkgsBuildBuild
}:

stdenv.mkDerivation {
  pname = "GUSI";
  version = "2.2.3";

  src = fetchurl {
    url = "mirror://sourceforge/gusi/GUSI/2.2.3/GUSI_223.sit.bin";
    hash = "sha256-DtCVifrzHcUFI+B637lacCsF+OsNSkWyI/miBW7F/94=";
  };

  nativeBuildInputs = with pkgsBuildBuild; [
    unar
  ];

  unpackPhase = ''
    unar -D $src
    mv GUSI_223/* .
  '';

  prePatch = ''
    rm include/dirent.h include/errno.h include/fcntl.h include/inttypes.h \
       include/machine/ansi.h include/machine/endian.h include/signal.h \
       include/sys/cdefs.h include/sys/errno.h include/sys/signal.h \
       include/sys/stat.h include/sys/time.h include/sys/types.h \
       include/sys/unistd.h include/unistd.h include/utime.h \
       include/**/*.rsrc
  '';

  installPhase = ''
    mkdir -p $out/lib

    for file in lib/*.MrC.Lib
    do
      mv $file ''${file%%.MrC.Lib}.o
    done

    cp -r include $out/include

    $AR rcs $out/lib/libGUSI.a lib/*.o
  '';
}
