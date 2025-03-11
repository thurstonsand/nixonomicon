{pkgs, ...}: {
  imports = [
    ./enhanced-homebrew.nix
    ./homebrew.nix
    ./launchd.nix
    ./nix-core.nix
    ./packages.nix
    ./users.nix
    ./macos.nix
  ];

  system = {
    stateVersion = 5;

    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.preUserActivation.text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system $systemConfig
    '';

    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  fonts = {
    packages = with pkgs; [
      font-awesome
      nerd-fonts.mononoki
    ];
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  # enable direnv/nix develop envs
  environment.systemPackages = with pkgs; [
    nix-direnv
  ];
}
