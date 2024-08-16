{ pkgs, inputs, settings, helpers, ... }: {
  imports = [
    ../../modules/networking/zerotier # Vpn tunnel
    ../../modules/networking/openvpn # Protonvpn configurations
    # ../../modules/networking/wiregaurd # Protonvpn configurations
    ../../modules/lang/rust.nix
    ../../modules/lang/sql.nix
    ../../modules/lang/go.nix
    ../../modules/io/bluetooth.nix # Bluetooth setup
    ../../modules/io/pipewire.nix # Audio server
    ../../modules/io/keyd.nix # Key remapping daemon
    ../../modules/apps/virtmanager.nix # Virtual machines
    ../../modules/sops.nix # Secrets management
    ../../modules/themes/rose-pine
    ../../modules/wm/awesome
    ../../modules/wm/hyprland
    ../gaming/configuration.nix # Games & related apps
    ../../modules/display-manager/sddm
    ../../modules/scripts/home-assistant.nix
    ../../modules/scripts/remote.nix
    ../../modules/scripts/deref.nix
    ../../modules/apps/git.nix
    ../../modules/apps/media/spotify
    ../../modules/apps/ollama.nix
    ../../modules/apps/lazygit.nix
    ../../modules/apps/terminal/kitty.nix
    ../../modules/apps/terminal/wezterm.nix
    ../../modules/apps/terminal/tmux.nix
    ../../modules/apps/shell/fish.nix
    ../../modules/apps/shell/zsh.nix
    ../../modules/apps/neovim.nix
    ../../modules/networking/samba/client.nix
    ../../modules/apps/browser/librewolf.nix
    ../../modules/apps/qbittorrent.nix
    inputs.stylix.nixosModules.stylix
    inputs.affinity.nixosModules.affinity
  ];

  config = {
    sops.secrets = { spotify_client_id = { owner = settings.user.username; }; };
    affinity = let path = "${settings.user.home}/affinity";
    in {
      prefix = "${path}/prefix";
      licenseViolations = "${path}/license_violations";
      user = settings.user.username;

      photo.enable = true;
      designer.enable = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    services.qbittorrent = {
      enable = false;
      settings = {
        Meta = { MigrationVersion = 6; };

        BitTorrent = {
          "Session\\Port" = 54406;
          "Session\\QueueingSystemEnabled" = false;
          "Session\\Interface" = "tun0";
          "Session\\InterfaceName" = "tun0";
        };

        Preferences = {
          "General\\Locale" = "en";
          "MailNotification\\req_auth" = true;
          "WebUI\\AuthSubnetWhitelist" = "@Invalid()";
          "WebUI\\LocalHostAuth" = false;
          "WebUI\\AlternativeUIEnabled" = true;
          "Session\\DefaultSavePath" = "${settings.user.home}/downloads";
          "WebUI\\Password_PBKDF2" =
            "@ByteArray(V5kcWZHn4FTxBM8IxsnsCA==:HPbgopaa1ZO199s4zmJAZfJ+gmGKUyAQMX1MjbphhHTtup80tt/FOFshUMRQnvCqAxAu31F6ziiUqpuUQCytPg==)";
          # "WebUI\\RootFolder" = alternativeWebUI;
        };
      };
    };

    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
    secrets.profile = "personal";

    openvpn.proton = {
      enable = true;
      profile = "nl-393";
    };

    fonts.packages = with pkgs;
      [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

    nixpkgs.config.packageOverrides = self: rec {
      blender = self.blender.override { cudaSupport = true; };
    };

    environment.systemPackages =
      let json_repair = pkgs.callPackage ../../pkgs/json_repair.nix { };
      in with pkgs; [
        # json_repair
        qdirstat
        blender
        activate-linux
        veracrypt
        handbrake
        dolphin
        mpv
        scrot
        sxiv
        cudatoolkit
        zip
        unzip
        xorg.xhost
        networkmanagerapplet
        usbutils
        firefox
        ethtool
        (pkgs.callPackage ../../modules/bluegone.nix { })
        (helpers.wrapPackage {
          name = "ffmpeg";
          package = pkgs.ffmpeg-full;
          extraFlags =
            "-hwaccel cuda -hwaccel_output_format cuda"; # (https://docs.nvidia.com/video-technologies/video-codec-sdk/12.0/ffmpeg-with-nvidia-gpu/index.html#hwaccel-transcode-without-scaling)
        })
      ];

    programs.thunar.enable = true;
    nixpkgs.config.allowUnfree = true;
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}

# sudo etherwake -i enp0s10 04:7C:16:EB:DF:9B
