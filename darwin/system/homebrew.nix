{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = true;
    };
    global = {
      autoUpdate = false;
    };

    taps = [
      "domt4/autoupdate"
      "rfidresearchgroup/proxmark3"
    ];

    brews = [
      "llm"
      # {
      #   name = "rfidresearchgroup/proxmark3/proxmark3";
      #   args = ["with-generic" "fetch-head"];
      #   conflicts_with = ["python"];
      # }
      "python"
    ];

    casks = [
      "1password"
      "1password-cli"
      "arc"
      "beeper"
      "chatgpt"
      "choosy"
      "contexts"
      "cursor"
      "discord"
      "fantastical"
      "ghostty"
      "google-chrome"
      "google-drive"
      "mac-mouse-fix"
      "macwhisper"
      "mimestream"
      "moonlight"
      "mqtt-explorer"
      "msty"
      "obsidian"
      "orbstack"
      "orion"
      "prusaslicer"
      "raycast"
      "rectangle-pro"
      "reflect"
      "replacicon"
      "setapp"
      "slack"
      "steam"
      "vlc"
      "wifiman"
      "windsurf"
      "zoom"
    ];

    validateMasApps = true;
    # NOTE: apps removed from this list are not uninstalled
    # a limitation of Homebrew Bundle
    # TODO: add back in when mas starts working again
    # > mas list
    # > Error: No installed apps found
    # masApps = {
    #   "Acorn 8" = 6737921844;
    #   "1Password for Safari" = 1569813296;
    #   "Access" = 6469049274;
    #   "Copilot" = 1447330651;
    #   "Dark Reader for Safari" = 1438243180;
    #   "Kagi for Safari" = 1622835804;
    #   "Mela" = 1568924476;
    #   "Parcel" = 639968404;
    #   "Play: Save Videos Watch Later" = 1596506190;
    #   "Save to Reader" = 1640236961;
    #   "Telegram" = 747648890;
    #   "TestFlight" = 899247664;
    #   "WhatsApp" = 310633997;
    #   "Wipr" = 1662217862; # actually Wipr 2
    #   "WireGuard" = 1451685025;
    #   "Xcode" = 497799835;
    # };
  };
}
