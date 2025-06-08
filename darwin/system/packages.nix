{
  pkgs,
  lib,
  config,
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
          editor = "cursor"; # Change to "cursor" to use Cursor instead
        in ''
          mkdir -p $out/bin
          ln -s /opt/homebrew/bin/${editor} $out/bin/code
        '';
      })
    ];
  };
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "Installing claude-code..."
    sudo -u ${config.system.primaryUser} env \
      HOME="/Users/${config.system.primaryUser}" \
      PATH="${pkgs.nodejs}/bin:$PATH" \
      npm_config_prefix="/Users/${config.system.primaryUser}/.npm-global" \
      npm_config_cache="/Users/${config.system.primaryUser}/.npm" \
      npm_config_userconfig="/Users/${config.system.primaryUser}/.npmrc" \
      ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
  '';
}
