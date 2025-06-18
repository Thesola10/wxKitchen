self: super: {
  palm = self.lib.makeScope self.newScope (selfScope: {
  ###### Local dev tools

    platforms = import ../packages/platform/palm/platforms.nix;

    sources = {
      prc-tools-remix = super.fetchFromGitHub {
        owner = "jichu4n";
        repo = "prc-tools-remix";
        rev = "master";
        hash = "sha256-03yTEMHkKtti+8kGKpU0xWQTOEHvNyp8Errowoe8JJY=";
      }; 

      palm-os-sdk = super.fetchFromGitHub {
        owner = "jichu4n";
        repo = "palm-os-sdk";
        rev = "master";
        hash = "sha256-sj5MmNSO+Pr3ipIbOhmUC4uYWdoCvcKj4tzguoJ0lCw=";
      };
    };

    pilrc = self.callPackage ../packages/platform/palm/pilrc {};

    sdk = self.palm.sdk_5r4;

    sdk_5r4 = "${self.palm.sources.palm-os-sdk}/sdk-5r4";

  } // super.lib.optionalAttrs (super.targetPlatform ? isPalm) {
  ###### Cross-compilers exclusively

    binutils_unwrapped = self.callPackage ../packages/platform/palm/binutils {};
    gcc_unwrapped = self.callPackage ../packages/platform/palm/gcc {};

    binutils = self.wrapBintoolsWith {
      bintools = self.palm.binutils_unwrapped;
      libc = null;
    };

    gcc = self.wrapCCWith {
      cc = self.palm.gcc_unwrapped;
      bintools = self.palm.binutils;
      libc = null;

      extraPackages = with self.targetPackages.palm; [

      ];
    };
  } // super.lib.optionalAttrs (super.hostPlatform ? isPalm) {
  ###### Native Palm libraries

  });

  binutils = if (super.targetPlatform ? isPalm)
             then self.palm.binutils
             else super.binutils;

  gcc = if (super.targetPlatform ? isPalm)
        then self.palm.gcc
        else super.gcc;
}
