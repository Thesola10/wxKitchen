{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg_original,
  pcre2,
  pkg-config,
  macSdk1028,
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
      ./0000-mac-drop-pascal-strings.patch
      ./0001-mac-disable-win32-defines.patch
      ./0002-mac-expose-strptime.patch
      ./0003-mac-add-retro68-detection.patch
      ./0004-mac-add-missing-unistd-h.patch
      ./0005-mac-fix-GetTempBuffer-declaration.patch
      ./0006-mac-fix-return-types.patch
    ];

  # This is how you know this software is very obsolete
  hardeningDisable = [ "all" ];

  CFLAGS = "-D_mkdir=mkdir -D_rmdir=rmdir -fpermissive -Wno-error=narrowing"
         + lib.optionalString isRetro68 " -D__WXMAC_OSX__";
  CXXFLAGS = "-D_mkdir=mkdir -D_rmdir=rmdir -fpermissive -Wno-error=narrowing"
           + lib.optionalString isRetro68 " -D__WXMAC_OSX__";

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
