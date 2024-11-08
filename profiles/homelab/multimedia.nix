{
  lib,
  config,
  helpers,
  inputs,
  ...
}:
let
  cfg = config.jellyfin;
  unstable = helpers.getPkgs inputs.nixpkgs-unstable;
in
{
  options.services = with lib; {
    radarr.port = mkOption {
      type = types.number;
      default = 7878;
    };
    sonarr.port = mkOption {
      type = types.number;
      default = 8989;
    };
    jackett.port = mkOption {
      type = types.number;
      default = 9117;
    };
  };

imports = [
../../modules/containers/jellyfin.nix
];

  config = {
    nixpkgs.config = lib.mkIf cfg.enableTorrent {
      packageOverrides = _: {
        inherit (unstable)
          jellyseerr
          radarr
          sonarr
          jackett
          ;
      };
    };

    services.jellyseerr = {
      enable = cfg.enableTorrent;
      openFirewall = true;
      port = 5055;
    };
    services.radarr = {
      enable = cfg.enableTorrent;
      openFirewall = true;
      group = "multimedia";
      # port = 7878
    };
    services.sonarr = {
      enable = cfg.enableTorrent;
      openFirewall = true;
      group = "multimedia";
      # port = 8989
    };
    services.jackett = {
      enable = cfg.enableTorrent;
      openFirewall = true;
      group = "multimedia";
      # port = 9117
    };
  };
}
