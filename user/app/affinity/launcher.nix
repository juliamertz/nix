{ lib, pkgs, config, ... }:
let 
  cfg = config.affinity;
  run_script = /*bash*/''
    winepath="${pkgs.wineElementalWarrior}"
    (return 0 2>/dev/null) && sourced=1 || sourced=0

    export WINEPREFIX="${cfg.prefix}"
    export PATH="$winepath/bin:$PATH"
    export LD_LIBRARY_PATH="$winepath/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export WINESERVER="$winepath/bin/wineserver"
    export WINELOADER="$winepath/bin/wine"
    export WINEDLLPATH="$winepath/lib/wine"

    if [[ $sourced == 0 ]]; then exec "$@"; fi
  '';
  binary = (pkgs.writeShellScriptBin "affinity" run_script);
in {
  nixpkgs.config.packageOverrides = pkgs: {
    affinity = binary;
  };
}
