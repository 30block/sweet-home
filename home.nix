{ config, pkgs, ... }:

{
  # Do not delete these lines
  home.username = "me";
  home.homeDirectory = "/home/me";

  home.sessionVariables = {
    # Set your preferred shell here.
    # Don't forget to add it to the `home.packages` section
    SWEET_HOME_SHELL = "sh";
  };

  # Additional packages to install
  home.packages = [
    # pkgs is the set of all packages in the default home.nix implementation
    # pkgs.nodejs-14_x
    # pkgs.curl
  ];

  # Add your programs and configurations here 
  programs.tmux = {
    enable = true;

    # Use same shortcut as screen
    shortcut = "a";

    # Resize to the size of the smallest session
    aggressiveResize = true;

    # Time in milliseconds for which tmux waits after an Esc
    escapeTime = 0;

    # Terminal type    
    terminal = "screen-256color";

    # Additional configurations
    extraConfig = ''
      # split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      set -g mouse on                           # enable mouse support
      set -g bell-action none                   # disable bell
      setw -g xterm-keys on                     # enable xterm keys
      set -g status-right '#(date +"%b %_d %H:%M") '
    '';
  };

  # Link other configuration files
  # home.file.".vimrc".source = ./vimrc;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
