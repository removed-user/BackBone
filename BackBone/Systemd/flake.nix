{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systemd_source = { url = "github:systemd/systemd"; flake = false;};
#systemd_liberated = { url = "github:systemd/systemd"; flake = false;};
systemd_liberated_patchfile pkgs.fetchurl {
  url = "";
  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}; url = "github:systemd/systemd"; flake = false;};

  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./systemd/flake-module.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.default = config.packages.systemd;

        packages.systemd = pkgs.callPackage ./systemd/package.nix { };
        checks.systemd = pkgs.callPackage ./systemd/test.nix {
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
