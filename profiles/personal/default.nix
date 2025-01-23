{
  pkgs,
  inputs,
  settings,
  helpers,
  dotfiles,
  ...
}:
let
  user = settings.user.username;
in
{
  config = {
    secrets.profile = "personal";

    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
    programs.appimage.binfmt = true;
    users.defaultUserShell = pkgs.zsh;
    programs.thunar.enable = true;

    sops.secrets = helpers.ownedSecrets user [ "openvpn_auth" ];

    # open ports for development
    networking.firewall.allowedTCPPorts = [
      1111
      1112
    ];

    nix.settings = {
      trusted-users = [ settings.user.username ];
      trusted-public-keys = [ "cache.juliamertz.dev-1:Jy4H1rmdG1b9lqEl5Ldy0i8+6Gqr/5DLG90r4keBq+E=" ];
    };

    environment.systemPackages =
      let
        scripts = import ../../modules/scripts { inherit pkgs; };
      in
      (with scripts; [
        dev
        wake
        comma
        fishies
      ])
      ++ (with dotfiles.pkgs; [
        neovim
        kitty
        lazygit
        tmux
      ])
      ++ (with pkgs; [
        qdirstat
        btop
        fastfetch
        mpv
        scrot
        sxiv
        xorg.xhost
        networkmanagerapplet
        usbutils
        firefox
        gh
        ethtool
      ]);
  };

  imports = [
    ../gaming

    ../../modules/networking/zerotier
    ../../modules/io/bluetooth.nix
    ../../modules/io/pipewire.nix
    ../../modules/sops.nix

    # desktop environment
    ../../modules/wm/awesome
    ../../modules/dm/sddm
    ../../modules/wm/hyprland
    ../../modules/io/keyd.nix
    ../../modules/themes/rose-pine

    # apps
    ../../modules/apps/virtmanager.nix
    ../../modules/scripts/home-assistant.nix
    ../../modules/apps/git.nix
    ../../modules/apps/media/spotify
    # ../../modules/apps/terminal/kitty.nix
    ../../modules/apps/terminal/wezterm.nix
    ../../modules/apps/shell/fish.nix
    ../../modules/apps/shell/zsh.nix
    ../../modules/networking/samba/client.nix
    ../../modules/nerdfonts.nix
    ../../modules/lang/lua.nix
    ../../modules/lang/nix.nix
    # ../modules/apps/browser/librewolf.nix
    # ../modules/apps/ollama.nix
    # ../modules/apps/affinity.nix
    # ../../modules/de/cosmic
    # ../modules/de/plasma
    # inputs.protonvpn-rs.nixosModules.protonvpn
    inputs.stylix.nixosModules.stylix
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
  ];

}
