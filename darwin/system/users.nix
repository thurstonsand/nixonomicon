let
  hostname = "Thurstons-MacBook-Pro";
  username = "thurstonsand";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];
}
