{ pkgs, settings, ... }:
let 
  user = settings.user.username;
in
{
  home.username = user;
  home.homeDirectory = "/home/${user}";

  programs.home-manager.enable = true;

  imports = [
    ../../user/app/tools/lazygit.nix
    ../../user/app/browser/firefox.nix
    ../../user/wm/awesome/home.nix
    ../../user/wm/picom/picom.nix
    ../../user/app/terminal/wezterm/home.nix
    ../../user/app/shell/fish.nix
    ../../user/app/shell/bash.nix
    ../../user/app/editor/nvim/home.nix
    ../../user/app/terminal/tmux.nix
    ../../user/app/affinity/home.nix
    ../../user/app/jellyfin.nix
    ../../user/app/tools/neofetch.nix
  ];

  affinity = {
    prefix = "/home/${user}/affinity/prefix";
    setup_prefix = false; # Only enable for fresh/unconfigured prefix
  };

  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  home.sessionVariables = {
    EDITOR = settings.system.editor; 
  };

  home.stateVersion = "24.05";
}
