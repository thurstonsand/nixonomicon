let
  username = "thurstonsand";
in {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # home files
    file = {
      ".codeium/windsurf/memories/global_rules.md" = {
        source = ./dotfiles/.codeium/windsurf/memories/global_rules.md;
        force = true;
      };
      "Library/Application Support/Windsurf/User" = {
        source = ./dotfiles/Library/${"Application Support"}/Windsurf/User;
        recursive = true;
        force = true;
      };
      "Library/Application Support/Storj/Uplink" = {
        source = ../common/platform_dependent_dotfiles/storj-uplink;
        recursive = true;
        force = true;
      };
      "Library/Application Support/Cursor/User/settings.json" = {
        source = ./dotfiles/Library/${"Application Support"}/Cursor/User/settings.json;
        force = true;
      };
    };
  };
  xdg.configFile = {
    "ghostty" = {
      source = ./dotfiles/.config/ghostty;
      recursive = true;
      force = true;
    };
  };
  xdg.configFile = {
    "nextdns.conf" = {
      source = ./dotfiles/.config/nextdns.conf;
      force = true;
    };
  };

  programs = {
    git.extraConfig = {
      "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    ssh.extraConfig = ''IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';

    zsh.shellAliases = {
      bd = "brew desc";
      bh = "brew home";
      switch = "darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixonomicon";
    };
  };
}
