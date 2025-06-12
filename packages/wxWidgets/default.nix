{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg_original,
  zlib,
  pcre2,
  pkg-config,
  buildPackages,

  retro68 ? null,

  unicode ? true,
  withMac ? stdenv.hostPlatform.retro68 or false,
  withMSW ? stdenv.hostPlatform.isWindows
}:

let
  isRetro68 = stdenv.hostPlatform.retro68 or false;

in stdenv.mkDerivation rec {
  pname = "wxWidgets";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "wxWidgets";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-pk7MObKe7GfmKz8AcXu9TRWmXoXbHqN0oWoaoOF8lfU=";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs =
    [
      libjpeg_original
      zlib
    ];

  buildInputs =
    lib.optionals (!isRetro68) [
      pcre2
    ];

  patches =
    # Despite targeting Mac OS Classic and including the Universal Interfaces,
    # Retro68 makes use of highly anachronistic, Linux-y semantics which we
    # need to patch in.
    # I can't just declare Retro68 a "Unix" because many key functions just
    # aren't implemented.
    lib.optionals isRetro68 [
      ./patches/0000-mac-drop-pascal-strings.patch
      ./patches/0001-mac-disable-win32-defines.patch
      ./patches/0002-mac-expose-strptime.patch
      ./patches/0003-mac-add-retro68-detection.patch
      ./patches/0004-mac-add-missing-unistd-h.patch
      ./patches/0005-mac-fix-GetTempBuffer-declaration.patch
      ./patches/0006-mac-fix-return-types.patch
      ./patches/0007-mac-define-verify-macros.patch
      ./patches/0008-mac-fix-corefoundation-includes.patch
    ];

  # This is how you know this software is very obsolete
  hardeningDisable = [ "all" ];

  CFLAGS = "-fpermissive -Wno-error=narrowing"
         + lib.optionalString stdenv.hostPlatform.isWindows " -D_mkdir=mkdir -D_rmdir=rmdir"
         + lib.optionalString isRetro68 " -DTARGET_API_MAC_OSX=0 -DTARGET_API_MAC_CARBON=1 -DBuildingMoreFilesXForMacOS9=1";
  CXXFLAGS = "-fpermissive -Wno-error=narrowing"
           + lib.optionalString stdenv.hostPlatform.isWindows " -D_mkdir=mkdir -D_rmdir=rmdir"
           + lib.optionalString isRetro68 " -DTARGET_API_MAC_OSX=0 -DTARGET_API_MAC_CARBON=1 -DBuildingMoreFilesXForMacOS9=1";

  LDFLAGS = lib.optionalString isRetro68 "-lCarbonFrameworkLib";

  REZ = lib.optionalString isRetro68 "${retro68.tools}/bin/Rez";
  SETFILE = lib.optionalString isRetro68
  (buildPackages.writeShellScript "SetFile"
  ''
  TYPE=APPL
  if [[ $1 == '-t' ]]
  then
    TYPE="$2"
    shift 2
  fi

  ${retro68.tools}/bin/MakePEF $1 -o $1.pef
  ${retro68.tools}/bin/Rez -I ${retro68.universal}/RIncludes ${retro68.libretro}/RIncludes/RetroCarbonAPPL.r -DCFRAG_NAME="\"$(basename $1)\"" --data $1.pef -o $1.bin -t $TYPE -c ro68
  '');

  postPatch = ''
    cat ${././mac-missing-glue.c} >> src/mac/carbon/utils.cpp
  '';

  configureFlags =
    [
      "--disable-shared"
      "--enable-gui"
      "--disable-monolithic"
      "--enable-filesystem"
      "--enable-vendor=wxKitchen"
      "--enable-url"
      "--enable-sound"
      "--disable-precomp-headers"
      "--with-libpng"
      "--with-libjpeg"
      "--with-flavour=wxKitchen"
      "--without-libtiff"
    ] ++ lib.optional isRetro68 [
      "--without-regex"
    ] ++ lib.optional withMSW "--with-msw"
      ++ lib.optional withMac "--with-mac"
      ++ lib.optional unicode "--with-unicode";

  postInstall = ''
    pushd $out/include
    ln -s wx-*/* .
    popd

    mkdir -p $out/nix-support
    $out/bin/wx-config --cflags > $out/nix-support/cc-cflags
    $out/bin/wx-config --cxxflags > $out/nix-support/libcxx-cxxflags
    $out/bin/wx-config --libs > $out/nix-support/cc-ldflags
    echo "-L${libjpeg_original}/lib -L${zlib}/lib" >> $out/nix-support/cc-ldflags
  '' + lib.optionalString isRetro68 ''
    echo "-DTARGET_API_MAC_OSX=0 -DTARGET_CARBON=1 -DTARGET_API_MAC_CARBON=1" >> $out/nix-support/cc-cflags
    echo "-DTARGET_API_MAC_OSX=0 -DTARGET_CARBON=1 -DTARGET_API_MAC_CARBON=1" >> $out/nix-support/libcxx-cxxflags
    echo "-lCarbonFrameworkLib -lQuickTimeLib -lCarbonLib" >> $out/nix-support/cc-ldflags
  '';

  enableParallelBuilding = true;

  passthru = {
    inherit withMSW withMac unicode;
  };

  meta = with lib; {
    homepage = "https://www.wxwidgets.org/";
    description = "Cross-Platform C++ GUI Library";
    license = licenses.wxWindows;
  };
}
