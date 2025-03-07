{
  inputs,
  pkgs,
  lib,
  settings,
  ...
}:
let
  addons = pkgs.callPackage ./addons.nix { inherit inputs; };
in
{
  home.config = {
    programs.librewolf = {
      enable = true;
      profiles.${settings.user.username} = {
        isDefault = true;

        extensions.packages = with addons; [
          vimium
          darkreader
          proton-pass
          alternate-twitch-player
          return-youtube-dislikes
          swagger-ui
          augmented-steam
          protondb-for-steam
          firefox-color

          stylus # userstyles
          greasemonkey # userscripts

          # adblocking
          ublock-origin
          sponsorblock
          i-dont-care-about-cookies
          disable-javascript

          # privacy
          privacy-badger
          decentraleyes
          leechblock-ng
        ];

        settings = {
          "browser.newtabpage.enabled" = false;
          # "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.startup.page" = 3;

          # automatically enable all extensions
          "extensions.autoDisableScopes" = 0;

          # "identity.fxaccounts.enabled" = false; # Disable fx accounts
          # Disable "save password" prompt
          "signon.rememberSignons" = false;

          # Harden
          "privacy.trackingprotection.enabled" = true;
          "dom.security.https_only_mode" = true;

          # Disable annoying first-run stuff
          "browser.disableResetPrompt" = true;
          "browser.download.panel.shown" = true;
          "browser.feeds.showFirstRunUI" = false;
          "browser.messaging-system.whatsNewPanel.enabled" = false;
          "browser.rights.3.shown" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.startup.homepage_override.mstone" = "ignore";
          "browser.uitour.enabled" = false;
          "startup.homepage_override_url" = "";
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.addedImportButton" = true;

          "browser.urlbar.quickactions.enabled" = false;
          "browser.urlbar.quickactions.showPrefs" = false;
          "browser.urlbar.shortcuts.quickactions" = false;
          "browser.urlbar.suggest.quickactions" = false;
        };

        search.engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
        };

        search.force = true;
      };
    };

    xdg.mimeApps.defaultApplications = lib.mkIf pkgs.stdenv.isLinux {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };
}
