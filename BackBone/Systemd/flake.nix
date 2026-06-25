{
  description = "Description for the project";

  #systemd_liberated = { url = "github:Jeffrey-Sardina/systemd"; flake = false;};
  #
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systemd_source = {
      url = "github:systemd/systemd";
      flake = false;
    };
    sd-liberated_patch = {
      url = "github:Jeffrey-Sardina/systemd-suite";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./systemd/flake-module.nix
        inputs.flake-parts.flakeModules.flakeModules
        inputs.flake-parts.flakeModules.modules
        inputs.flake-parts.flakeModules.debug
      ];

      disabledModules = [
        inputs.flake-parts.flakeModules.nixosModules
        inputs.flake-parts.flakeModules.nixosConfigurations
        inputs.flake-parts.flakeModules.apps
        inputs.flake-parts.flakeModules.devShells
        inputs.flake-parts.flakeModules.formatter
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        debug = true;
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.default = config.packages.systemd;

        packages.systemd = pkgs.callPackage ./systemd/package.nix {};
        checks.systemd =
          pkgs.callPackage ./systemd/test.nix {
          };
        flake = {
          # The usual flake attributes can be defined here, including system-
          # agnostic ones like nixosModule and system-enumerating ones, although
          # those are more easily expressed in perSystem.
        };
      };
    };
}
