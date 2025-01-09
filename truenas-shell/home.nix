{pkgs, ...}: {
  home = {
    username = "admin";
    homeDirectory = "/config";
    sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs = {
    zsh.shellAliases = {
      switch = "nix run /config/Develop/nixonomicon -- switch --flake .#truenas-shell";
    };
  };
}
