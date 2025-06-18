{
  lib,
  stdenv,
  fetchFromGitea,
  wxWidgets,
  buildPackages,
}:

let
  # Stand-in noop script to configure ourselves without GHC
  nil = buildPackages.writeShellScript "nil" ''
    true
  '';
in stdenv.mkDerivation rec {
  pname = "wxc";
  version = "0.9.4";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wxHaskell";
    repo = "wxHaskell";
    rev = "wxhakell-0-9-4";
    hash = "sha256-0bfQztJb434Zkzp0+7/yTz2OrTYtCKf3BhZbvVdIe/E=";
  };

  NIX_CFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/cc-cflags"
                     + " -fpermissive"
                     + lib.optionalString stdenv.hostPlatform.isLinux " -fPIC";
  NIX_CXXFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/libcxx-cxxflags"
                     + " -fpermissive"
                     + lib.optionalString stdenv.hostPlatform.isLinux " -fPIC";

  buildInputs = [
    wxWidgets
  ];

  patches = [
    # This lets all wxWidgets C++ classes be defined as incomplete structs of
    # same name, providing a semblance of type safety and more useful tooltips
    # in language servers.
    ./patches/c-typed-interface.patch

    # Lots of features get disabled between backends and platforms, we need to
    # conditionally remove them here too lest compilation fails.
    ./patches/conditional-features.patch

    # This adds a static building option and fixes the -Wl flag for Linux targets
    ./patches/makefile-fixes.patch
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    ./patches/linux-include-time.patch
  ] ++ lib.optionals (stdenv.hostPlatform ? retro68) [
    ./patches/mac-fix-darwin-detection.patch
    ./patches/mac-fix-wxcolour-return-type.patch
  ];

  hardeningDisable = [ "all" ];

  enableParallelBuilding = true;

  configurePhase = ''
    PATH=${wxWidgets}/bin:$PATH ./configure --prefix=$out --hc=${nil} --hcpkg=${nil}
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES wxc-bindist AR=$AR
  '';

  installPhase = ''
    cp -r out/bindist/wxhaskell-${version} $out
    cp -r wxc/include $out/include

    $CXX -dM -E -x c++ `cat ${wxWidgets}/nix-support/libcxx-cxxflags` ${wxWidgets}/include/wx/wx.h |grep -E 'wx[A-Z0-9_]+ ' > $out/include/wx_constants.h
    grep -zoPh 'enum .*\n?{(.|\n)*?};\n' ${wxWidgets}/include/wx/defs.h >> $out/include/wx_constants.h
    cd $out/lib
    ln -s libwxc-*.a libwxc.a
  '' + lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -s libwxc-*.so libwxc.so
  '';
}
