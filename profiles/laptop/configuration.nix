{ pkgs, lib, inputs, settings, config, ... }:
let
  user = settings.user.username;
  platform = settings.system.platform;
  home-manager = inputs.home-manager.darwinModules.home-manager;
in {
  imports = [
    home-manager
  ];

  services.nix-daemon.enable = true;

  environment.shells = [pkgs.fish];
  environment.systemPackages = [
    inputs.nix-darwin
    pkgs.fish
  ];

  # system.activationScripts.setFishAsShell.text = ''
  #   dscl . -create /Users/${user} UserShell /run/current-system/sw/bin/fish
  # '';

  users.knownUsers = [ user ];

  users.users.${user} = {
    home = "/Users/${user}";
    # shell = "${pkgs.fish}/bin/fish";
    uid = 501;
  };

  # programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = config._module.specialArgs;
  };

  home-manager.users.${user} = { pkgs, ... }: {
    imports = [ 
      ./home.nix
    ];
  };
}
