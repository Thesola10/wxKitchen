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
          (import ./overlays/macos.nix {
            pkgsRetro68 = retro68.legacyPackages.${system}.pkgsCross.carbon.retro68;
            pathToRetro68 = retro68;
          })
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
    };

    makePkgsCross = platform: import nixpkgs {
      inherit system;
      inherit (platform) crossSystem overlays;
      config.allowUnsupportedSystem = true;
    };

    pkgs = import nixpkgs {
      inherit system;
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
        "wxWidgets-${r}" = (makePkgsCross platforms.${r}).buildWxApp {
          name = "wxKitchen-shell";
          src = pkgs.emptyDirectory;
        };
        "wxc-${r}" = (makePkgsCross platforms.${r}).buildWxApp {
          name = "wxKitchen-shell-with-wxc";
          src = pkgs.emptyDirectory;
          withWxc = true;
        };
      }) {} (builtins.attrNames platforms);
  });
}
