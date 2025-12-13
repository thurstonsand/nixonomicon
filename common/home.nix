{pkgs, ...}: let
  npxAlias = pkg: "npx -y ${pkg}";
in {
  home = {
    packages = with pkgs; [
      ack
      ast-grep
      cf-terraforming
      deno
      # does not have all encoders enabled -- homebrew version does
      # ffmpeg-full
      fh
      git-credential-manager
      git-crypt
      git-trim
      just
      lazygit
      nixd
      nextdns
      nix-inspect
      nix-prefetch-github
      nodejs
      opentofu
      prettyping
      rclone
      # in case repo has been stuck in locked state:
      # restic --repo rclone:storj:windows-backup/mnt/capacity/backup/ unlock
      restic
      storj-uplink
      tldr
      tree
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
    "lazygit" = {
      source = ./dotfiles/.config/lazygit;
      recursive = true;
      force = true;
    };
  };

  programs = {
    home-manager.enable = true;

    bash.enable = true;

    bat.enable = true;

    btop.enable = true;

    bun = {
      enable = true;
      enableGitIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = false; # Manually integrated with caching for performance
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
      enableZshIntegration = false; # Manually integrated with caching for performance
    };

    git = {
      enable = true;
      ignores = [
        ".DS_Store"
        ".cache"
        ".nix"
      ];
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GpY+hdZp60Fbnk9B03sntiJRx7OgLwutV5vJpV6P+";
        signByDefault = true;
      };
      lfs.enable = true;
      settings = {
        user = {
          name = "Thurston Sandberg";
          email = "thurstonsand@gmail.com";
        };
        alias.pushf = "push --force-with-lease";
        color.ui = "auto";
        credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        gpg.format = "ssh";
        init.defaultBranch = "main";
        pull.rebase = true;
        push = {
          default = "simple";
          autoSetupRemote = true;
        };
        rebase.autoStash = true;
      };
    };

    gh = {
      enable = true;
      settings = {
        editor = "code --wait";
        git_protocol = "ssh";
      };
    };

    go = {
      enable = true;
      telemetry.mode = "local";
    };

    htop.enable = true;

    jq.enable = true;

    # WARNING: git-crypt not supported
    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Thurston Sandberg";
          email = "thurstonsand@gmail.com";
        };
        ui = {
          editor = "code --wait";
          # Use the tool defined in [merge-tools] below for interactive sessions
          diff-editor = "code";
          merge-editor = "code";
          graph.style = "curved"; # Valid: "curved", "square", "ascii", "ascii-large"
          movement.edit = true;
        };

        # Aliases for common stack operations
        aliases = {
          # Show just your current stack
          stack = [
            "log"
            "-r"
            "::@ & ~::main"
          ];
          # Go to root of current stack
          bottom = [
            "edit"
            "roots(::@ & ~::main)"
          ];
          # Show what would be pushed for a branch
          preview = [
            "log"
            "-r"
            "::@"
            "--git"
          ];
        };

        merge-tools.code = {
          program = "code";
          # Args for `jj split`, `jj squash -i`, etc.
          edit-args = [
            "--wait"
            "--diff"
            "$left"
            "$right"
          ];
          # Args for `jj resolve`
          merge-args = [
            "--wait"
            "--merge"
            "$left"
            "$right"
            "$base"
            "$output"
          ];
        };

        signing = {
          behavior = "drop";
          backend = "ssh";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GpY+hdZp60Fbnk9B03sntiJRx7OgLwutV5vJpV6P+";
          # TODO: this is a mac-only setting, so needs to be moved there
          backends.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };

        git = {
          sign-on-push = true;
          auto-local-bookmark = true;
          private-commits = "description(glob:'wip:*') | description(glob:'private:*')";
        };

        # Custom log output formatting
        templates = {
          log_node = ''
            coalesce(
              if(!self, label("elided", "~")),
              label(if(current_working_copy, "working_copy"),
                if(conflict, label("conflict", "×"), "◉")
              ),
            )
          '';
        };
      };
    };

    nix-index = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false; # Disabled for performance
    };
    nix-index-database = {
      comma.enable = true;
    };

    nvchad = {
      enable = true;
      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        (python3.withPackages (
          ps:
            with ps; [
              python-lsp-server
              flake8
            ]
        ))
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
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          addKeysToAgent = "no";
          hashKnownHosts = false;
        };

        "nix" = {
          hostname = "nix.thurstons.house";
          user = "thurstonsand";
          forwardAgent = true;
        };

        "truenas" = {
          hostname = "truenas.thurstons.house";
          user = "admin";
          forwardAgent = true;
          # TERM override not needed if tic is run:
          # https://ghostty.org/docs/help/terminfo#copy-ghostty's-terminfo-to-a-remote-machine
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
      enableZshIntegration = false; # Manually integrated with caching for performance
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
        gcloud.disabled = true;
      };
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        vim-lastplace
      ];
      defaultEditor = false; # try to use neovim instead
      extraConfig = builtins.readFile ./dotfiles/.vimrc;
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      autocd = true;
      enableCompletion = true;

      # Optimize compinit - only rebuild completion cache once per day
      # Uses zsh glob qualifiers for faster checking (no subprocess spawning)
      completionInit = ''
        autoload -Uz compinit
        # Only regenerate .zcompdump if it's older than 24 hours
        # The glob qualifier (mh+24) checks for files modified more than 24 hours ago
        if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qNmh+24) ]]; then
          compinit
        else
          compinit -C  # Skip security check for faster startup
        fi
      '';

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
        size = 10000;
        save = 10000;
      };

      defaultKeymap = "emacs";

      profileExtra = ''
        # Cache directory for eval command outputs
        ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
        mkdir -p "$ZSH_CACHE_DIR"

        # Caching function for eval commands
        # Regenerates cache if: binary updated, cache missing, or args changed
        _evalcache() {
          local cmd=$1
          shift
          local cache_file="$ZSH_CACHE_DIR/''${cmd##*/}_init.zsh"
          local binary=$(command -v "$cmd" 2>/dev/null)

          # Regenerate if binary is newer, cache missing, or command changed
          if [[ ! -f "$cache_file" ]] || \
             [[ -n "$binary" && "$binary" -nt "$cache_file" ]] || \
             [[ "$cmd $*" != "$(head -1 "$cache_file" 2>/dev/null | sed 's/^# //')" ]]; then
            echo "# $cmd $*" > "$cache_file"
            "$cmd" "$@" >> "$cache_file" 2>/dev/null
            zcompile "$cache_file" 2>/dev/null || true
          fi
          source "$cache_file"
        }
      '';

      initContent = ''
        # Initialize tools with caching
        # Interactive-only tools
        if [[ -o interactive ]]; then
          _evalcache fzf --zsh
          _evalcache zoxide init zsh --cmd cd
          if [[ $TERM != "dumb" ]]; then
            _evalcache starship init zsh
          fi
        fi
        _evalcache direnv hook zsh

        # Extended glob operators
        setopt EXTENDED_GLOB       # treat #, ~, and ^ as part of patterns for filename generation

        # Input/Output
        setopt INTERACTIVE_COMMENTS # allow comments in interactive shells

        # Job Control
        setopt NOTIFY              # report the status of background jobs immediately

        # Extra key bindings
        bindkey "^[[3~" delete-char
        # bindkey "^[[3;9~" kill-line
        bindkey "^U" backward-kill-line
      '';

      shellAliases = {
        ping = "prettyping";
        top = "htop";
        lg = "lazygit";
        codex = npxAlias "@openai/codex";
        gemini = npxAlias "@google/gemini-cli";
        openskills = npxAlias "openskills";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = false; # Manually integrated with caching for performance
      options = [
        "--cmd cd"
      ];
    };
  };
}
