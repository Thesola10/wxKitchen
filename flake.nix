{
  inputs = {
    "nixpkgs".url = github:NixOS/nixpkgs/nixos-23.11;

    "retro68".url = github:autc04/Retro68;

    "prc-tools".url = github:jichu4n/prc-tools-remix;
    "prc-tools".flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, retro68, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    retro68Platforms = (import "${retro68}/nix/platforms.nix");

    platforms = {
      "ppc-macos" = {
        crossSystem = retro68Platforms.carbon;
        overlays = [
          retro68.overlays.default
          (import ./overlays/macos.nix)
          (import ./overlays/all.nix)
        ];
      };
      "i686-mingw32" = {
        crossSystem = pkgs.pkgsCross.mingw32.stdenv.hostPlatform;
        overlays = [
          (import ./overlays/mingw32.nix)
          (import ./overlays/all.nix)
        ];
      };
      "i686-linux24" = {
        crossSystem = pkgs.pkgsCross.musl32.pkgsStatic.stdenv.hostPlatform;
        overlays = [
          (import ./overlays/linux.nix)
          (import ./overlays/all.nix)
        ];
      };
    };

    makePkgsCross = platform: import nixpkgs {
      inherit system;
      inherit (platform) crossSystem overlays;
      config.allowUnsupportedSystem = true;
    };

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (import ./overlays/all.nix)
      ];
    };
  in {
    legacyPackages = pkgs;

    packages = {
      pkgsCross = builtins.mapAttrs (_: makePkgsCross) platforms;
    } // builtins.foldl'
      (l: r: l // {
        "demo-${r}" = (makePkgsCross platforms.${r}).wxkitchen-demo;
        "c-demo-${r}" = (makePkgsCross platforms.${r}).wxkitchen-c-demo;
      }) {} (builtins.attrNames platforms);

    devShells = builtins.foldl'
      (l: r: l // {
        "wxWidgets-${r}" =
          let pkgs = makePkgsCross platforms.${r};
          in pkgs.buildWxApp {
          name = "wxKitchen-shell";
          src = pkgs.emptyDirectory;

          nativeBuildInputs = pkgs.lib.optionals (pkgs.stdenv.hostPlatform ? isRetro68) [
            pkgs.retro68.tools
          ];
        };
        "wxc-${r}" = self.devShells.${system}."wxWidgets-${r}".overrideAttrs {
          withWxc = true;
        };
      }) {} (builtins.attrNames platforms);
  });
}
