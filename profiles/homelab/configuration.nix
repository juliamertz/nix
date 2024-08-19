{ pkgs, settings, config, ... }: {
  imports = [
    ../../modules/containers/home-assistant.nix
    ../../modules/containers/jellyfin.nix
    ../../modules/containers/sponsorblock-atv.nix
    ../../modules/networking/zerotier # Vpn tunnel
    ../../modules/sops.nix # Secrets management
    ../../modules/apps/git.nix
    ../../modules/apps/terminal/tmux.nix
    ../../modules/apps/shell/zsh.nix
    ../../modules/apps/neovim.nix
    ../../modules/apps/lazygit.nix
    ../../modules/lang/lua.nix
    ../../modules/networking/openvpn # Protonvpn configurations
    ../../modules/apps/qbittorrent
    ../../modules/networking/samba/server.nix
  ];

  jellyfin = let user = settings.user.home;
  in {
    configDir = "${user}/jellyfin";
    volumes = [
      "/home/media/shows:/shows"
      "/home/media/movies:/movies"
      "/home/media/music:/music"
    ];
  };

  openvpn.proton = {
    enable = true;
    profile = "nl-393";
  };

  services.qbittorrent = {
    enable = true;
    port = 8280;
    openFirewall = true;

    user = settings.user.username;
    group = "users";

    settings = {
      Meta = { MigrationVersion = 6; };
      Core = { AutoDeleteAddedTorrentFile = "Never"; };

      BitTorrent = {
        Session-Interface = "tun0";
        Session-InterfaceName = "tun0";
        Session-DefaultSavePath = /home/media/downloads;
        Session-DisableAutoTMMByDefault = false;
        Session-DisableAutoTMMTriggers-CategorySavePathChanged = false;
      };

      Preferences = {
        General-Locale = "en";
        WebUI-LocalHostAuth = false;
        WebUI-Password_PBKDF2 =
          "@ByteArray(V5kcWZHn4FTxBM8IxsnsCA==:HPbgopaa1ZO199s4zmJAZfJ+gmGKUyAQMX1MjbphhHTtup80tt/FOFshUMRQnvCqAxAu31F6ziiUqpuUQCytPg==)";
        # WebUI-AlternativeUIEnabled = true;
        # WebUI-RootFolder = config.services.qbittorrent.userInterfaces.darklight;
      };
    };

    flood = { enable = true; };
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  nixpkgs.config.allowUnfree = true;
  secrets.profile = "personal";

  environment.systemPackages = with pkgs; [ btop fastfetch diskonaut busybox ];
}
