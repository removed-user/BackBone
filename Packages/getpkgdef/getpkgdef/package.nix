{
  stdenv,
  lib,
  runtimeShell,
}: let
  # Bring fileset functions into scope.
  # See https://nixos.org/manual/nixpkgs/stable/index.html#sec-functions-library-fileset
  inherit (lib.fileset) toSource unions;

  _local_bin = /bin/tee;
in
  # Example package in the style that `mkDerivation`-based packages in Nixpkgs are written.
  stdenv.mkDerivation (finalAttrs: {
    name = "getpkgdef";
    src = toSource {
      root = ./.;
      fileset = unions [
        ./getpkgdef.bash
      ];
      #    nativeBuildInputs
    };
    buildPhase = ''
      # Note that Nixpkgs has builder functions for simple packages
      # like this, but this template avoids it to make for a more
      # complete example.
      substitute getpkgdef.bash getpkgdef --replace '@shell@' ${runtimeShell}
      cat getpkgdef
      chmod a+x getpkgdef
    '';
    installPhase = ''
      install -D getpkgdef $out/bin/getpkgdef
    '';
  })
