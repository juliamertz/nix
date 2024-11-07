#!/usr/bin/env sh

FLAKE=$(dirname $0)
KERNEL=$(uname -s)

if [[ $KERNEL == "Linux" ]]; then
  # sudo nixos-generate-config --show-hardware-config > $FLAKE/hardware-configuration.nix
  sudo nixos-rebuild switch --flake $FLAKE

elif [[ $KERNEL == "Darwin" ]]; then
  nix run --extra-experimental-features "nix-command flakes" \
    nix-darwin -- switch --flake $FLAKE
fi
