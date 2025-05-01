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
      {
        name = "rfidresearchgroup/proxmark3/proxmark3";
        args = ["with-generic" "HEAD"];
        conflicts_with = ["python"];
      }
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
      "qlmarkdown"
      "raycast"
      "rectangle-pro"
      "reflect"
      "replacicon"
      "setapp"
      "slack"
      "steam"
      "vlc"
      "voiceink"
      "warp"
      "wifiman"
      "windsurf"
      "zoom"
    ];

    validateMasApps = true;
    # NOTE: apps removed from this list are not uninstalled
    # a limitation of Homebrew Bundle
    masApps = {
      "1Password for Safari" = 1569813296;
      "Acorn 8" = 6737921844;
      "Access" = 6469049274;
      "Copilot" = 1447330651;
      "Dark Reader for Safari" = 1438243180;
      "Kagi for Safari" = 1622835804;
      "Logger for Shortcuts" = 1611554653;
      "Mela" = 1568924476;
      "Orb.net" = 6477840170;
      "Parcel" = 639968404;
      "Play: Save Videos Watch Later" = 1596506190;
      "Save to Reader" = 1640236961;
      "Telegram" = 747648890;
      "TestFlight" = 899247664;
      "WhatsApp" = 310633997;
      "Wipr" = 1662217862; # actually Wipr 2
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };
  };
}
