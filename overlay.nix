self: super: {

  # Lower the API threshold to Windows NT4
  windows =
  let mingw_ver = "6.0.1";
      mingw_src = super.pkgsBuildBuild.fetchurl {
        url = "mirror://sourceforge/mingw-w64/mingw-w64-v${mingw_ver}.tar.bz2";
        hash = "sha256-AZBbdG3NzXO7nA7kRjYmyJZB1VordD+7XbqUEuztP2Q=";
      };
  in super.windows // {
    mingw_w64 = super.windows.mingw_w64.overrideAttrs
      (prev: {
        version = mingw_ver;
        src = mingw_src;
        patches = [];
        configureFlags = [
          "--with-default-win32-winnt=0x0400"
        ];
      });

    mingw_w64_headers = super.windows.mingw_w64_headers.overrideAttrs
      (prev: {
        name = "mingw-w64-${mingw_ver}-headers";
        src = mingw_src;
        configureFlags = [
          "--with-default-win32-winnt=0x0400"
        ];
      });

    mingw_w64_pthreads = super.windows.mingw_w64_pthreads.overrideAttrs
      (prev: {
        name = "mingw-w64-${mingw_ver}-pthreads";
        src = mingw_src;
        configureFlags = [
          "--with-default-win32-winnt=0x0400"
        ];
      });
  };

  wxWidgets = self.callPackage ./packages/wxWidgets {};

  wxc = self.callPackage ./packages/wxc {};

  buildWxApp = self.callPackage ./buildWxApp.nix {};

  wxkitchen-demo = self.callPackage ./packages/demo {};

  stdenv =
    if super.stdenv.hostPlatform.isWindows
    then super.overrideCC super.stdenv
      (super.stdenv.cc.override (old: {
        cc = old.cc.override {
          threadsCross = {
            model = "win32";
            package = null;
          };
        };
      }))
    else super.stdenv;
}
