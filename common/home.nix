{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      ack
      ffmpeg
      fh
      git-credential-manager
      git-crypt
      git-trim
      just
      nextdns
      nix-inspect
      nix-prefetch-github
      nodejs
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

    btop.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config.global = {
        # Make direnv messages less verbose
        hide_env_diff = true;
      };
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

    gh = {
      enable = true;
      settings = {
        editor = "vim";
        git_protocol = "ssh";
      };
    };

    htop.enable = true;

    jq.enable = true;

    # git-crypt not supported, so leaving this alone for now
    # jujutsu = {
    #   enable = true;
    #   settings = {
    #     user = {
    #       name = "Thurston Sandberg";
    #       email = "thurstonsand@gmail.com";
    #     };
    #     ui = {
    #       editor = "vim";
    #     };
    #     fix.tools."1-nix-fmt" = {
    #       command = "nix fmt";
    #       patterns = ["**/*.nix"];
    #     };
    #     signing = {
    #       sign-all = true;
    #       backend = "ssh";
    #       key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GpY+hdZp60Fbnk9B03sntiJRx7OgLwutV5vJpV6P+";
    #       # TODO: this is a mac-only setting, so needs to be moved there
    #       backends.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    #     };
    #     git = {
    #       sign-on-push = true;
    #       auto-local-bookmark = true;
    #       private-commits = "description(glob:'wip:*') | description(glob:'private:*')";
    #     };
    #   };
    # };

    nix-index = {
      enable = true;
    };
    nix-index-database = {
      comma.enable = true;
    };

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
          setEnv = {
            TERM = "xterm-256color";
          };
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
        directory = {
          truncation_length = 0; # Show full path
          truncate_to_repo = false; # Don't truncate to repo root
          style = "bold yellow"; # Style for non-repo path
          repo_root_style = "bold yellow"; # Style for repo path
          before_repo_root_style = "dimmed cyan"; # Style for path before repo
          format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style) ";
        };
        nix_shell = {
          format = "env [$symbol$state]($style) ";
          symbol = "❄️ ";
          pure_msg = "pure";
          impure_msg = "dev";
          style = "bold blue";
        };
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
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "pattern"
          "line"
          "cursor"
          "root"
        ];
      };
      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        size = 1000;
        save = 10000;
      };

      initContent = ''
        # Extended glob operators
        setopt EXTENDED_GLOB       # treat #, ~, and ^ as part of patterns for filename generation

        # Input/Output
        setopt INTERACTIVE_COMMENTS # allow comments in interactive shells

        # Job Control
        setopt NOTIFY              # report the status of background jobs immediately

        # Key bindings
        # bindkey "^[[3~" delete-char
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
        "--cmd cd"
      ];
    };
  };
}
