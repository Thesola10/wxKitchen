self: super: {

  hfsfuse = self.callPackage ../packages/platform/macos/hfsfuse {};

  macb = self.callPackage ../packages/platform/macos/macb {};

  GUSI = self.callPackage ../packages/platform/macos/GUSI {};

  # The Universal Interfaces shipped with Retro68's Nix files is too old,
  # so we need to fetch and patch in a new one.
  retro68 =
    if super.stdenv.hostPlatform ? retro68
    then super.retro68.overrideScope'
      (current: prev: {
        universalInterfaces_342 = super.pkgsBuildBuild.fetchurl {
          url = "http://web.archive.org/web/20170606210919if_/http://staticky.com/mirrors/ftp.apple.com/developer/Development_Kits/UniversalInterfaces3.4.2.img.bin";
          hash = "sha256-irehExm4c9x5oGVz10lc1ijSSHqf1wEht6+z7OZ+ImY=";
        };

        libretro = prev.libretro.overrideAttrs (prevAttrs: {
          buildCommand = prevAttrs.buildCommand + ''
            patch $out/RIncludes/RetroCarbonAPPL.r < ${../extras/mac-libretro-increase-default-ram.patch}
            ln -s libretrocrt-carbon.a $out/lib/libretrocrt.a
          '';
        });

        universal = self.stdenvNoCC.mkDerivation {
          name = "retro68.universal";
          src = self.retro68.universalInterfaces_342;
          nativeBuildInputs = with self.buildPackages; [
            retro68.tools
            retro68.binutils_unwrapped
            hfsfuse
            macb
          ];

          buildCommand = let
            pathToRetro68 = super.buildPackages.retro68.monolithic.src;
          in ''
            ConvertDiskImage $src decoded.dsk
            export HOME=.
            hfstar decoded.dsk - --rsrc-ext=.rsrc | tar -xf -
            mkdir -p $out/include $out/RIncludes
            bash ${pathToRetro68}/prepare-headers.sh Universal/Interfaces/CIncludes $out/include
            bash ${pathToRetro68}/prepare-rincludes.sh Universal/Interfaces/RIncludes $out/RIncludes

            . ${pathToRetro68}/interfaces-and-libraries.sh

            mv Universal/Libraries/PPCLibraries libppc
            mv Universal/Libraries/StubLibraries peflibs
            for file in peflibs/*.rsrc
            do
              macb -c ''${file%%.rsrc}.bin -d ''${file%%.rsrc} -r $file -T stub
            done

            PPCLIBRARIES=libppc
            SHAREDLIBRARIES=peflibs
            INTERFACELIB=peflibs/InterfaceLib.bin

            setupPPCLibraries $out/
            mv $out/libppc $out/lib

            patch $out/include/OpenTransport.h < ${../extras/mac-universal-fix-macro-conflict.patch}

            patch -p1 -d $out/RIncludes < ${../extras/mac-universal-fix-rez-syntax.patch}

            ln -s Quickdraw.h $out/include/QuickDraw.h

            ln -s . $out/include/Carbon
          '';
        };

        tools = self.buildPackages.retro68.tools;
      })
    else super.retro68;

  stdenv =
    if super.stdenv.hostPlatform ? retro68
    then super.overrideCC super.stdenv
      (super.stdenv.cc.override (prev: {
        extraBuildCommands = ''
          mkdir -p $out/lib $out/include
          echo "-L${self.retro68.universal}/lib" >> $out/nix-support/cc-ldflags
          echo "-I${self.retro68.universal}/include" >> $out/nix-support/cc-cflags
          cp ${../extras/ansi_fp.h} $out/include/ansi_fp.h
        '';
        extraPackages = with self.retro68; [
          universal
          import_libraries
          libretro
          setup_hook
        ];
      }))
    else super.stdenv;
}
