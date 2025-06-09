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
    overlays =
    [
      (import ./overlay.nix)
    ];

    retro68Platforms = (import "${retro68}/nix/platforms.nix");

    platforms = {
      "ppc-macos" = retro68Platforms.powerpc;
      "i686-mingw32" = pkgs.pkgsCross.mingw32.stdenv.hostPlatform // {
        retro68 = false;
      };
    };

    makePkgsCross = crossSystem: import nixpkgs {
      inherit system crossSystem;
      overlays = overlays ++ (
        if crossSystem.retro68 then retro68.overlays.default else []
      );
      config.allowUnsupportedSystem = true;
    };

    pkgs = import nixpkgs {
      inherit system overlays;
    };
  in {
    legacyPackages = pkgs;

    packages = {
      pkgsCross = builtins.mapAttrs
        (_: makePkgsCross) platforms;
    } // builtins.foldl'
      (l: r: l // { "demo-${r}" = (makePkgsCross platforms.${r}).wxkitchen-demo; })
      {} (builtins.attrNames platforms);
  });
}
