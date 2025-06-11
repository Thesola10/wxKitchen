{ pkgsRetro68 ? null }:

self: super: {

  # The Universal Interfaces shipped with Retro68's Nix files is too old,
  # so we need to fetch and patch in a new one.
  macSdk1028 = super.pkgsBuildBuild.fetchzip {
    url = "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX10.2.8.sdk.tar.xz";
    hash = "sha256-OMTS3t2xBjTYQisFT7zER+e04E9gQiozCXBxrVoIPzw=";
  };

  stdenv =
    if super.stdenv.hostPlatform.retro68 or false
    then super.overrideCC super.stdenv
      (super.stdenv.cc.override (old: {
        extraBuildCommands = ''
          mkdir -p $out/lib $out/include
          ln -s ${pkgsRetro68.libretro}/lib/libretrocrt-carbon.a $out/lib/libretrocrt.a
          echo "-L${self.retro68.universal}/lib" >> $out/nix-support/cc-ldflags
          cp ${../extras/ansi_fp.h} $out/include/ansi_fp.h

          echo "-DTARGET_CPU_PPC=1 -D__APPLE_CC__" >> $out/nix-support/cc-cflags
          echo "-isystem ${old.cc}/powerpc-apple-macos/include" >> $out/nix-support/cc-cflags
          echo "-isystem $out/include" >> $out/nix-support/cc-cflags
          echo "-isystem ${self.macSdk1028}/Developer/Headers/CFMCarbon" >> $out/nix-support/cc-cflags
          echo "-L${self.macSdk1028}/usr/lib" >> $out/nix-support/cc-ldflags
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
    else super.stdenv;
}
