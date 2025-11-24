{
  pkgs,
  # lib,
  # config,
  ...
}: {
  environment = {
    pathsToLink = ["/share/zsh"];
    systemPackages = with pkgs; [
      cmake
      duti
      imagemagick
      nil
      pkg-config

      # TODO: wait for 1.69 to come out:
      # https://github.com/rclone/rclone/pull/7717
      # also take a look at https://github.com/l3uddz/cloudplow?tab=readme-ov-file#automatic-scheduled
      # rclone

      sqlite-utils
      uv

      (symlinkJoin {
        name = "code";
        paths = [];
        postBuild = let
          # Options include:
          # code-insiders
          # code
          # cursor
          # surf
          # zed
          editor = "windsurf";
        in ''
          mkdir -p $out/bin
          ln -s /opt/homebrew/bin/${editor} $out/bin/code
        '';
      })
    ];
  };
  # system.activationScripts.postActivation.text = lib.mkAfter ''
  #   echo "Installing global node packages..."
  #   sudo -u ${config.system.primaryUser} sh -c '
  #     export HOME="/Users/${config.system.primaryUser}"
  #     export XDG_CACHE_HOME="/Users/${config.system.primaryUser}/.cache"
  #     PATH="${pkgs.nodejs}/bin:$PATH" \
  #     ${pkgs.nodejs}/bin/npm install -g @google/gemini-cli @openai/codex @musistudio/claude-code-router\
  #       --prefix="/Users/${config.system.primaryUser}/.npm-global" \
  #       --cache="/Users/${config.system.primaryUser}/.npm" \
  #       --userconfig="/Users/${config.system.primaryUser}/.npmrc"
  #   '
  # '';
}
