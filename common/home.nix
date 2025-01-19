{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      ack
      fh
      git-credential-manager
      git-crypt
      # TODO: remove the override once this bug is fixed
      # got error where zlib headers were not found
      (pkgs.git-trim.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [pkgs.zlib];
      }))
      # TODO: Check back in to see if this is available:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/in/inshellisense/package.nix
      # must be >0.0.1-rc.18
      # inshellisense
      nix-prefetch-github
      prettyping
      rclone
      # in case repo has been stuck in locked state:
      # restic --repo rclone:storj:windows-backup/mnt/capacity/backup/ unlock
      restic
      storj-uplink
      tldr
      unzip
    ];
    stateVersion = "23.05";
  };
  xdg.configFile = {
    "rclone" = {
      source = ./dotfiles/.config/rclone;
      recursive = true;
      force = true;
    };
  };

  programs = {
    home-manager.enable = true;

    bash.enable = true;

    bat.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      ignores = [
        ".DS_Store"
        ".vscode"
        ".cache"
        ".nix"
      ];
      userName = "Thurston Sandberg";
      userEmail = "thurstonsand@gmail.com";
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GpY+hdZp60Fbnk9B03sntiJRx7OgLwutV5vJpV6P+";
        signByDefault = true;
      };
      lfs.enable = true;
      extraConfig = {
        color.ui = "auto";
        credential.helper = "/usr/local/share/gcm-core/git-credential-manager";
        gpg.format = "ssh";
        init.defaultBranch = "main";
        pull.rebase = true;
        push = {
          default = "simple";
          autoSetupRemote = true;
        };
      };
    };

    htop.enable = true;

    nvchad = {
      enable = true;
      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        (python3.withPackages (ps:
          with ps; [
            python-lsp-server
            flake8
          ]))
      ];

      chadrcConfig = ''
        ---@type ChadrcConfig
        local M = {}

        M.ui = {
          theme = 'catppuccin',
          transparency = true,
        }

        return M
      '';

      hm-activation = true;
      backup = false;
    };

    ripgrep = {
      enable = true;
    };

    ssh = {
      enable = true;

      serverAliveInterval = 60;
      serverAliveCountMax = 3;

      matchBlocks = {
        "nix" = {
          hostname = "nix.thurstons.house";
          user = "thurstonsand";
          forwardAgent = true;
        };

        "truenas" = {
          hostname = "truenas.thurstons.house";
          user = "admin";
          forwardAgent = true;
          setEnv = {
            # not needed if tic is run:
            # https://ghostty.org/docs/help/terminfo#copy-ghostty's-terminfo-to-a-remote-machine
            # TERM = "xterm-256color";
          };
        };

        "truenas-dev" = {
          hostname = "192.168.6.227";
          user = "admin";
          port = 2222;
          forwardAgent = true;
        };

        "haos" = {
          hostname = "192.168.1.89";
          user = "root";
          forwardAgent = true;
          setEnv = {
            TERM = "xterm-256color";
          };
        };
      };
    };

    starship = {
      enable = true;
      settings = {
        hostname.disabled = true;
        username.disabled = true;
      };
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [vim-nix vim-lastplace];
      defaultEditor = false; # try to use neovim instead
      extraConfig = builtins.readFile ./dotfiles/.vimrc;
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      autocd = true;
      enableCompletion = true;
      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        size = 1000;
        save = 10000;
      };

      initExtra = ''
        # Extended glob operators
        setopt EXTENDED_GLOB       # treat #, ~, and ^ as part of patterns for filename generation

        # Input/Output
        setopt INTERACTIVE_COMMENTS # allow comments in interactive shells

        # Job Control
        setopt NOTIFY              # report the status of background jobs immediately

        # Key bindings
        bindkey "^[[3~" delete-char
      '';

      shellAliases = {
        "ping" = "prettyping";
        "top" = "htop";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd j"
      ];
    };
  };
}
