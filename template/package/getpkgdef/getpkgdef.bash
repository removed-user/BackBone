echo $(nix eval --raw nixpkgs#systemd.meta.position | cut -d: -f1)
