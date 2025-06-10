{ pkgsRetro68 ? null }:

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

  wxkitchen-c-demo = self.callPackage ./packages/cdemo {};
  wxkitchen-demo = self.callPackage ./packages/demo {};

  macSdk1028 = super.pkgsBuildBuild.fetchzip {
    url = "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX10.2.8.sdk.tar.xz";
    hash = "sha256-OMTS3t2xBjTYQisFT7zER+e04E9gQiozCXBxrVoIPzw=";
  };

  stdenv =
    if super.stdenv.hostPlatform.isWindows then
      super.overrideCC super.stdenv
      (super.stdenv.cc.override (old: {
        cc = old.cc.override {
          threadsCross = {
            model = "win32";
            package = null;
          };
        };
        extraBuildCommands = ''
          echo "-static-libstdc++" >> $out/nix-support/libcxx-cxxflags
          echo "-static-libgcc" >> $out/nix-support/cc-cflags
        '';
      }))
    else if (super.stdenv.hostPlatform.retro68 or false) then
      super.overrideCC super.stdenv
      (super.stdenv.cc.override (old: {
        extraBuildCommands = ''
          mkdir -p $out/lib $out/include
          ln -s ${pkgsRetro68.libretro}/lib/libretrocrt-carbon.a $out/lib/libretrocrt.a
          echo "-L${pkgsRetro68.universal}/lib" >> $out/nix-support/cc-ldflags
          cp ${./extras/ansi_fp.h} $out/include/ansi_fp.h

          echo "-DTARGET_CPU_PPC=1 -D__APPLE_CC__" >> $out/nix-support/cc-cflags
          echo "-isystem ${old.cc}/powerpc-apple-macos/include" >> $out/nix-support/cc-cflags
          echo "-isystem $out/include" >> $out/nix-support/cc-cflags
          echo "-isystem ${self.macSdk1028}/Developer/Headers/CFMCarbon" >> $out/nix-support/cc-cflags
          echo "-L$out/lib" >> $out/nix-support/cc-ldflags
        '';
        extraPackages = with pkgsRetro68; [
          universal
          import_libraries
          libretro
          self.macSdk1028
          setup_hook
        ];
      }))
    else
      super.stdenv
    ;
}
