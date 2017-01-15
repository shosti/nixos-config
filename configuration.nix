# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include machine-specific config
      ./machine-configuration.nix
      ./pkgs/droid-slashed/default.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.supportedFilesystems = [ "zfs" ];

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    vlc
    ffmpeg
    wget
    acpi
    htop
    vim
    dmenu
    chromium
    git
    emacs25
    gnupg
    silver-searcher
    syncthing
    ruby
    rxvt_unicode-with-plugins
    xsel
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      font-droid
      font-droid-sans-mono-slashed
      emojione
      noto-fonts
    ];
  };

  programs.bash.enableCompletion = true;

  services.xserver = {
    enable = true;
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    desktopManager.xterm.enable = false;

    synaptics = {
      enable = true;
      horizEdgeScroll = false;
      horizTwoFingerScroll = true;
      vertEdgeScroll = false;
      vertTwoFingerScroll = true;
      additionalOptions = ''
        Option "VertScrollDelta" "-111"
        Option "HorizScrollDelta" "-111"
      '';
    };
  };

  users.extraUsers.shosti = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/shosti";
  };

  services.syncthing = {
    user = "shosti";
    enable = true;
    useInotify = true;
    dataDir = "/home/shosti/.syncthing";
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs25;
    defaultEditor = true;
  };

  security.sudo.wheelNeedsPassword = false;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
