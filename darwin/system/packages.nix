{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    imagemagick
    nil
  ];
}
