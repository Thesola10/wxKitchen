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
      retro68.overlays.default
      (import ./overlay.nix)
    ];

    retro68Platforms = (import "${retro68}/nix/platforms.nix");

    platforms = {
      "ppc-macos" = retro68Platforms.powerpc;
    };

    pkgs = import nixpkgs {
      inherit system overlays;
    };
  in {
    legacyPackages = pkgs;

    packages.pkgsCross = builtins.mapAttrs
      (name: crossSystem: import nixpkgs {
        inherit system crossSystem overlays;
        config.allowUnsupportedSystem = true;
      }) platforms;
  });
}
