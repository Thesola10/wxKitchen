{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg_original,
  zlib,
  pcre2,
  gtk2,
  pkg-config,
  libX11,
  buildPackages,

  retro68 ? null,

  unicode ? true,
  withMac ? stdenv.hostPlatform.retro68 or false,
  withMSW ? stdenv.hostPlatform.isWindows,
  withGTK2 ? /* stdenv.hostPlatform.isLinux */ false,
  withUniversal ? ! (withMac || withMSW || withGTK2)
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
    ] ++ lib.optionals withGTK2 [
      gtk2
    ] ++ lib.optionals (withUniversal && stdenv.hostPlatform.isLinux) [
      libX11
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
      ./patches/mac/0000-drop-pascal-strings.patch
      ./patches/mac/0001-disable-win32-defines.patch
      ./patches/mac/0002-expose-strptime.patch
      ./patches/mac/0003-add-retro68-detection.patch
      ./patches/mac/0004-add-missing-unistd-h.patch
      ./patches/mac/0005-fix-GetTempBuffer-declaration.patch
      ./patches/mac/0006-fix-return-types.patch
      ./patches/mac/0007-define-verify-macros.patch
      ./patches/mac/0008-fix-corefoundation-includes.patch
      ./patches/mac/0009-fix-gsocket-includes.patch
    ] ++ [
      # wxc needs this to be public, which for some reason on X11 alone it isn't.
      ./patches/x11/0000-dataform-make-settype-public.patch

      # By making select wxHTTP and wxSocket members virtual, I can redirect
      # writes through Crypto Ancienne and easily implement HTTPS (see curling)
      ./patches/1000-virtual-http-socket.patch
    ];

  # This is how you know this software is very obsolete
  hardeningDisable = [ "all" ];

  CFLAGS =
    [
      "-fpermissive"
      "-Wno-error=narrowing"
    ] ++ lib.optionals stdenv.hostPlatform.isWindows [
      "-D_mkdir=mkdir"
      "-D_rmdir=rmdir"
    ] ++ lib.optionals stdenv.hostPlatform.isLinux [
      "-fPIC"
    ] ++ lib.optionals isRetro68 [
      "-DTARGET_API_MAC_OSX=0"
      "-DTARGET_API_MAC_CARBON=1"
      "-DBuildingMoreFilesXForMacOS9=1"
    ];
  CXXFLAGS = CFLAGS;

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

  postPatch = lib.optionalString isRetro68 ''
    cat ${./mac-missing-glue.c} >> src/mac/carbon/utils.cpp
    sed -ie 's/wxUSE_SOCKETS=no/wxUSE_SOCKETS=yes/g' configure
    sed -ie 's/wxUSE_THREADS=no/wxUSE_THREADS=yes/g' configure
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
      "--enable-gif"
      "--disable-precomp-headers"
      "--with-libpng"
      "--with-libjpeg"
      "--with-flavour=wxKitchen"
      "--without-libtiff"
    ] ++ lib.optionals isRetro68 [
      "--without-regex"
    ] ++ lib.optionals withMSW [
      "--with-msw"
    ] ++ lib.optionals withMac [
      "--with-mac"
    ] ++ lib.optionals withGTK2 [
      "--with-gtk=2"
    ] ++ lib.optionals withUniversal [
      "--enable-universal"
    ] ++ lib.optionals (withUniversal && stdenv.hostPlatform.isLinux) [
      "--with-x11"
    ] ++ lib.optionals unicode [
      "--with-unicode"
    ];

  postInstall = ''
    pushd $out/include
    ln -s wx-*/* .
    popd

    mkdir -p $out/nix-support
    $out/bin/wx-config --cflags > $out/nix-support/cc-cflags
    $out/bin/wx-config --cxxflags > $out/nix-support/libcxx-cxxflags
    $out/bin/wx-config --libs > $out/nix-support/cc-ldflags
    echo "-L${libjpeg_original}/lib -L${zlib}/lib" >> $out/nix-support/cc-ldflags

    # Compatibility with wxSkinToy's CMakeLists
    touch $out/wx-config.in
    ln -s . $out/wx-config
  '' + lib.optionalString isRetro68 ''
    $CC -E -P -I ${retro68.universal}/RIncludes - < src/mac/carbon/corersrc.r > corersrc.full.r
    ${retro68.tools}/bin/Rez corersrc.full.r -o $out/lib/libwx_base_carbon.bin

    cp include/MacHeaders.c $out/lib/wx/include/*/

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
