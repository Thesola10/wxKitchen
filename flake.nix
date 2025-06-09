{
  inputs = {
    "nixpkgs".url = github:NixOS/nixpkgs/nixos-23.11;

    "retro68".url = github:autc04/Retro68;
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

    pkgs = import nixpkgs {
      inherit system overlays;
    };
  in {
    legacyPackages = pkgs;

    packages.pkgsCross = {
      ppc-macos = import nixpkgs {
        inherit system overlays;
        config.allowUnsupportedSystem = true;
        crossSystem = retro68Platforms.powerpc;
      };
    };
  });
}
