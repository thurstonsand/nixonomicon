{pkgs, ...}: {
  environment = {
    pathsToLink = ["/share/zsh"];
    systemPackages = with pkgs; [
      imagemagick
      nil

      # TODO: wait for 1.69 to come out:
      # https://github.com/rclone/rclone/pull/7717
      # also take a look at https://github.com/l3uddz/cloudplow?tab=readme-ov-file#automatic-scheduled
      # rclone

      (symlinkJoin {
        name = "code";
        paths = [];
        postBuild = let
          editor = "cursor"; # Change to "windsurf" to use Windsurf instead
        in ''
          mkdir -p $out/bin
          ln -s /opt/homebrew/bin/${editor} $out/bin/code
        '';
      })
    ];
  };
}
