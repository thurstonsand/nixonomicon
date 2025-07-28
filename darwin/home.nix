{
  pkgs,
  lib,
  ...
}: let
  username = "thurstonsand";
in {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    sessionPath = ["$HOME/.npm-global/bin" "$HOME/.opencode/bin"];
    sessionVariables = {
      EDITOR = "code --wait";
    };

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

  # Configure default applications using duti
  home.activation.setDefaultApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Set Cursor as default for text files
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .txt all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .md all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .json all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .js all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .ts all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .tsx all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .jsx all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .py all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .rb all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .go all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .rs all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .toml all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .yaml all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .yml all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .xml all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .css all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .sh all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .bash all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .zsh all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 .nix all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 public.plain-text all
    ${pkgs.duti}/bin/duti -s com.todesktop.230313mzl4w4u92 public.source-code all
  '';

  programs = {
    git.extraConfig = {
      "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    ssh = {
      includes = [
        "~/.ssh/1Password/config"
      ];

      extraConfig = ''IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
    };

    zsh.shellAliases = {
      bd = "brew desc";
      bh = "brew home";
      opencode = "/Users/thurstonsand/.opencode/bin/opencode";
      switch = "sudo darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixonomicon";
    };
  };
}
