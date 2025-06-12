{
  lib,
  stdenv,
  fetchFromGitea,
  wxWidgets,
  buildPackages,
}:

let
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

  buildInputs = [
    wxWidgets
  ];

  patches = [
    ./c-typed-interface.patch
  ];

  hardeningDisable = [ "all" ];

  configurePhase = ''
    PATH=${wxWidgets}/bin:$PATH ./configure --prefix=$out --hc=${nil} --hcpkg=${nil}
  '';

  buildPhase = ''
    make wxc-bindist
  '';

  installPhase = ''
    cp -r out/bindist/wxhaskell-${version} $out
    cp -r wxc/include $out/include

    $CXX -dM -E -x c++ `cat ${wxWidgets}/nix-support/libcxx-cxxflags` ${wxWidgets}/include/wx/wx.h |grep -E 'wx[A-Z0-9_]+ ' > $out/include/wx_constants.h
    grep -zoPh 'enum .*\n?{(.|\n)*?};\n' ${wxWidgets}/include/wx/defs.h >> $out/include/wx_constants.h
    cd $out/lib
    ln -s libwxc-*.a libwxc.a
  '';
}
