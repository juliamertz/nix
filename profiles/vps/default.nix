{ settings, inputs, dotfiles, ... }:
let
  inherit (settings.system) platform hostname;
  inherit (settings.user) username fullName home;
in
{
  config = {
    secrets.profile = "vps";

    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      trusted-public-keys = [ "cache.juliamertz.dev-1:Jy4H1rmdG1b9lqEl5Ldy0i8+6Gqr/5DLG90r4keBq+E=" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    nixpkgs.hostPlatform = platform;
    networking.hostName = hostname;

    openssh = {
      enable = true;
      harden = true;
    };

    environment.systemPackages =
      with dotfiles.pkgs;
      [
        zsh
        tmux
        neovim
        lazygit
      ];

    system.stateVersion = "24.05";

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
      flake = "${home}/nix";
    };
  };

  imports = [
    ./wiregaurd.nix
    ./caddy.nix
    ./services/valnetten.nix

    ../../modules/apps/git.nix
    ../../modules/io/ssh.nix
    ../../modules/apps/neovim.nix
    ../../modules/sops.nix
  ];
}
