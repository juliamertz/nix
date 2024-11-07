#!/usr/bin/env sh

SSH_KEY=~/.ssh/id_ed25519

if [ -f $SSH_KEY ]; then
  mkdir -p ~/.config/sops/age
  nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i $SSH_KEY > ~/.config/sops/age/keys.txt"
else 
  echo No ssh key found, skipping age key generation.
fi
