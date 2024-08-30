{ pkgs, settings, inputs, helpers, ... }:
let user = settings.user.username;
in {
  imports = [
    ../modules/io/ssh.nix
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
  ];

  config = mkMerge [
    (if helpers.isDarwin then
      {
        # Darwin defaults
      }
    else {
      # Nixos defaults stuff
      environment.systemPackages = with pkgs; [ xclip ];

      networking.firewall.enable = true;
      networking.networkmanager.enable = true;

      users.users.${user} = {
        isNormalUser = true;
        description = settings.user.fullName;
        extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
      };

      time.timeZone = settings.system.timeZone;
      i18n.defaultLocale = settings.system.defaultLocale;
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "nl_NL.UTF-8";
        LC_IDENTIFICATION = "nl_NL.UTF-8";
        LC_MEASUREMENT = "nl_NL.UTF-8";
        LC_MONETARY = "nl_NL.UTF-8";
        LC_NAME = "nl_NL.UTF-8";
        LC_NUMERIC = "nl_NL.UTF-8";
        LC_PAPER = "nl_NL.UTF-8";
        LC_TELEPHONE = "nl_NL.UTF-8";
        LC_TIME = "nl_NL.UTF-8";
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = "/home/${user}/nix";
      };

      system.stateVersion = "24.05";
    })
    # Shared defaults
    {
      environment.systemPackages = with pkgs; [ openssl curl tldr zip unzip ];
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      networking.hostName = settings.system.hostname;
    }
  ];
}
