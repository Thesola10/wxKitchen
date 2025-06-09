self: super: {

  # Lower the API threshold to Windows NT4
  windows =
  let mingw_src = super.pkgsBuildBuild.fetchurl {
        url = "mirror://sourceforge/mingw-w64/mingw-w64-v7.0.0.tar.bz2";
        hash = "sha256-qiDf/zWW8Ip/QnqrdDFabLgMKwhrShB+01rwL5SWtig=";
      };
  in super.windows // {
    mingw_w64 = super.windows.mingw_w64.overrideAttrs
      (prev: {
        version = "7.0.0";
        src = mingw_src;
        configureFlags = [
          "--with-default-win32-winnt=0x0400"
        ];
      });

    mingw_w64_headers = super.windows.mingw_w64_headers.overrideAttrs
      (prev: {
        name = "mingw-w64-7.0.0-headers";
        src = mingw_src;
        configureFlags = [
          "--with-default-win32-winnt=0x0400"
        ];
      });

    mingw_w64_pthreads = super.windows.mingw_w64_pthreads.overrideAttrs
      (prev: {
        name = "mingw-w64-7.0.0-pthreads";
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

  #stdenv =
  #  if super.stdenv.hostPlatform.isWindows
  #  then super.withCFlags [
  #    "-D_WIN32_WINNT=0x0400"
  #    "-DWINVER=0x0400"
  #  ] super.stdenv
  #  else super.stdenv;
}
