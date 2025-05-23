{pkgs, ...}: {
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
}
