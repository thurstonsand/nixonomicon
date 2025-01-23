{...}: {
  system.defaults = {
    # customize dock
    dock = {
      autohide = true;
      orientation = "left";
      show-process-indicators = true;
      show-recents = false;
      mru-spaces = false;
    };

    finder = {
      _FXShowPosixPathInTitle = true;
      # icnv = icon view
      # nlsv = list view
      # clmv = column view
      # flwv = cover flow view
      FXPreferredViewStyle = "ncnv";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    menuExtraClock.Show24Hour = true;

    NSGlobalDomain = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    # Desktop Services
    CustomUserPreferences."com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };
}
