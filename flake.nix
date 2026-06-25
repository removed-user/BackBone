{
  description = "Flake basics described using the module system";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs = inputs @ {nixpkgs-lib, ...}: let
    lib = import ./lib.nix {
      inherit (nixpkgs-lib) lib;
      # Extra info for version check message
      revInfo =
        if nixpkgs-lib?rev
        then " (nixpkgs-lib.rev: ${nixpkgs-lib.rev})"
        else "";
    };
    templates = {
      #      default = {
      #        path = ./template/default;
      #        description = ''
      #          A minimal flake using flake-parts.
      #        '';
      #      };
      #      multi-module = {
      #        path = ./template/multi-module;
      #        description = ''
      #          A minimal flake using flake-parts.
      #        '';
      #      };
      # unfree = {
      #   path = ./template/unfree;
      #   description = ''
      #     A minimal flake using flake-parts importing nixpkgs with the unfree option.
      #   '';
      # };
    };
    BackBone = {
      Kernel = {
        path = ./BackBone/Kernel;
        description = ''
          A Kernel Config (upcoming);
          - Minimal
          - X scheduler
        '';
      };
      Systemd = {
        path = ./BackBone/Systemd;
        decription = ''
           The systemd package, init, but with a somewhat reasonable scope
          - Includes custom feature-set
          - all (current) meson options
        '';
      };
      packages = {
        imports = [./Packages/flake.nix];
        path = ./Packages;
        description = ''
          A flake with a simple package:
          - Nixpkgs
          - callPackage
          - src with fileset
          - a check with runCommand
        '';
      };
    };
    flakeModules = {
      easyOverlay = ./extras/easyOverlay.nix;
      flakeModules = ./extras/flakeModules.nix;
      modules = ./extras/modules.nix;
      partitions = ./extras/partitions.nix;
      bundlers = ./extras/bundlers.nix;
    };
  in
    lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        inputs.flake-parts.flakeModules.modules
        inputs.flake-parts.flakeModules.debug
        inputs.flake-parts.flakeModules.partitions
      ];

      disabledModules = [
        inputs.flake-parts.flakeModules.nixosModules
        inputs.flake-parts.flakeModules.nixosConfigurations
        inputs.flake-parts.flakeModules.apps
        inputs.flake-parts.flakeModules.devShells
        inputs.flake-parts.flakeModules.formatter
      ];
      # partitionedAttrs.checks = "dev";
      # partitionedAttrs.herculesCI = "dev";
      # partitions.dev.extraInputsFlake = ./dev;
      partitions.dev.module = {
        imports = [./dev/flake-module.nix];
        partitionedAttrs.devShells = "dev";
      };
      flake = {
        inherit lib templates flakeModules BackBone;
      };
    };
}
