{
  pkgs,
  lib,
  settings,
  inputs,
  helpers,
  ...
}:
let
  unstable = helpers.getPkgs inputs.nixpkgs-unstable;
  inherit (lib) mkDefault;
  inherit (settings.user) username fullName;
  inherit (settings.system) platform hostname;
in
{
  imports = [ ../../modules/settings.nix ];

  config = {
    environment.systemPackages = with pkgs; [
      openssl
      curl
    ];

    nixpkgs.config.allowUnfree = mkDefault true;
    nix = {
      package = unstable.nix;
      settings = {
        experimental-features = mkDefault [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];

        trusted-public-keys = [ "cache.juliamertz.dev-1:Jy4H1rmdG1b9lqEl5Ldy0i8+6Gqr/5DLG90r4keBq+E=" ];
        trusted-users = [
          "root"
          settings.user.username
        ];
      };
    };

    nixpkgs.hostPlatform = mkDefault platform;
    networking.hostName = mkDefault hostname;

    users.users.${username} = {
      description = fullName;
      inherit (settings.user) home;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaSMVfNtTgKjZBn0OurWXDpNrV+soaog7W0Svv4vE40"
      ];
    };
  };
}
