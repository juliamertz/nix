{
  settings,
  ...
}:
let
  inherit (settings.system) platform hostname;
  inherit (settings.user) username fullName home;
  #
  lightspeed-dhl-adapter = import (builtins.fetchGit {
    url = "https://github.com/juliamertz/lightspeed-dhl-adapter.git";
    rev = "63f8a7dc6e8a3cf4d97eb7a80fac3f6832dfbfaf";
  }) { system = builtins.currentSystem; }.default;

in
{
  config = {
    environment.systemPackages = [ lightspeed-dhl-adapter ];

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.hostPlatform = platform;
    networking.hostName = hostname;

    openssh = {
      enable = true;
      harden = true;
    };

    users.users.${username} = {
      description = fullName;
      inherit home;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaSMVfNtTgKjZBn0OurWXDpNrV+soaog7W0Svv4vE40"
      ];
    };

    networking.firewall.enable = true;
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.utf-8";

    boot.loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/${username}/nix";
    };

  };
  imports = [
    ../modules/apps/git.nix
    ../modules/io/ssh.nix
    ../modules/apps/neovim.nix
    # ../modules/apps/terminal/tmux.nix
    # ../modules/apps/lazygit.nix
  ];
}
