{
  lib,
  stdenv,
  fetchFromGitHub,
  libpng,
  libjpeg_original,
  pcre2,
  pkg-config,
  unicode ? true,
  withMac ? stdenv.hostPlatform.retro68,
  withMSW ? stdenv.hostPlatform.isWindows
}:
stdenv.mkDerivation rec {
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
      libpng
      libjpeg_original
    ];

  buildInputs =
    [
      pcre2
    ];

  # This is how you know this software is very obsolete
  hardeningDisable = [ "all" ];

  CFLAGS = "-D_mkdir=mkdir -D_rmdir=rmdir -fpermissive -Wno-error=narrowing";
  CXXFLAGS = "-D_mkdir=mkdir -D_rmdir=rmdir -fpermissive -Wno-error=narrowing";

  configureFlags =
    [
      "--disable-shared"
      "--enable-gui"
      "--enable-monolithic"
      "--enable-filesystem"
      "--enable-vendor=wxKitchen"
      "--enable-url"
      "--enable-sound"
      "--disable-precomp-headers"
      "--with-libpng"
      "--with-libjpeg"
      "--without-libtiff"
    ]
    ++ lib.optional withMSW "--with-msw"
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
