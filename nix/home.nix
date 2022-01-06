{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    # userName = "me";
    # userEmail = "me@gmail.com";
  };
  
  programs.tmux = {
    enable = true;
    # Use same shortcut as screen
    shortcut = "a";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
