{ config, pkgs, ... }:

{
  # Add your programs and configurations here
  programs.tmux = {
    enable = true;
    # Use same shortcut as screen
    shortcut = "a";
  };
  
  # Link configuration files
  # home.file.".gitconfig".source = ./vimrc;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
