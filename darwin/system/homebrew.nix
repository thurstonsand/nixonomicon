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
      "nikitabobko/tap"
      "rfidresearchgroup/proxmark3"
      "sst/tap"
    ];

    # more up-to-date or available versions
    brews = [
      "cliproxyapi"
      "llm"
      "ffmpeg"
      {
        name = "rfidresearchgroup/proxmark3/proxmark3";
        args = [
          "with-generic"
          "HEAD"
        ];
        conflicts_with = ["python"];
      }
      "python" # dependency for proxmark3
      "rustup-init"
    ];

    casks = [
      "1password"
      "1password-cli"
      # "aerospace"
      "aqua-voice"
      "bazecor"
      "beeper"
      "chatgpt"
      # "choosy"
      "claude"
      "clay"
      "cloudflare-warp"
      "contexts"
      "cursor"
      "elgato-camera-hub"
      "elgato-control-center"
      "fantastical"
      "ghostty"
      "google-chrome"
      "gcloud-cli"
      # "google-drive" # Deprecated somehow?
      "iina"
      "legcord"
      "localsend"
      "mac-mouse-fix"
      # "macwhisper"
      "mimestream"
      "monodraw"
      "moonlight"
      # "mqtt-explorer"
      "obsidian"
      "orbstack"
      "orion"
      "prusaslicer"
      "qlmarkdown"
      "raycast"
      "rectangle-pro"
      # "reflect"
      "setapp"
      "slack"
      "steam"
      # "tabtab"
      "visual-studio-code"
      "visual-studio-code@insiders"
      "warp"
      "wifiman"
      "windsurf"
      "zed"
      "zoom"
    ];

    # TODO: Re-enable validateMasApps once the sudo uid issue is resolved
    validateMasApps = false;
    # NOTE: apps removed from this list are not uninstalled
    # a limitation of Homebrew Bundle
    masApps = {
      "1Password for Safari" = 1569813296;
      "Acorn 8" = 6737921844;
      "Copilot" = 1447330651;
      "Infuse" = 1136220934;
      "Kagi for Safari" = 1622835804;
      "Keepa - Price Tracker" = 1533805339;
      "Keyword Search" = 1558453954;
      "Logger for Shortcuts" = 1611554653;
      "Mela" = 1568924476;
      "Noir – Dark Mode for Safari" = 1592917505;
      "Obsidian Web Clipper" = 6720708363;
      "Parcel" = 375589283;
      "Perplexity: Ask Anything" = 6714467650;
      "Play: Save Videos Watch Later" = 1596506190;
      "Poolsuite FM" = 1514817810;
      "Raycast Companion" = 6738274497;
      "Remind Me Faster" = 985555908;
      # "Save to Reader" = 1640236961;
      "Spokenly: Voice to Text AI" = 6740315592;
      "SponsorBlock for Safari" = 1573461917;
      "Tailscale" = 1475387142;
      "Telegram" = 747648890;
      "TestFlight" = 899247664;
      "Uplock" = 6469049274;
      "WhatsApp Messenger" = 310633997;
      "Wipr" = 1662217862; # actually Wipr 2
      # "Xcode" = 497799835;
    };
  };
}
