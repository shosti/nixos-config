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
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.tmpOnTmpfs = true;

  boot.zfs = {
    forceImportAll = false;
    forceImportRoot = false;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    vlc
    ffmpeg
    wget
    acpi
    htop
    direnv
    vim
    dmenu
    chromium
    git
    emacs25
    pinentry
    gnupg
    silver-searcher
    syncthing
    rxvt_unicode-with-plugins
    xsel
    aspell
    aspellDicts.en
    usbutils
    hfsprogs
    xautolock
    xorg.xmodmap
    tree
    pass
    pwgen
    isync
    msmtp
    psmisc
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      font-droid
      (import ./pkgs/droid-slashed.nix)
      noto-fonts
      noto-fonts-emoji
      symbola
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
  services.tlp.enable = true;
  services.timesyncd.enable = true;

  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
  };

  users.extraUsers.shosti = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/shosti";
  };

  virtualisation.virtualbox.host.enable = true;

  services.syncthing = {
    user = "shosti";
    enable = true;
    useInotify = true;
    dataDir = "/home/shosti/.syncthing";
  };

  services.postgresql = {
    enable = true;
  };

  services.redis = {
    enable = true;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs25;
    defaultEditor = true;
  };

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
  };

  services.physlock = {
    enable = true;
    user = "shosti";
  };

  services.dovecot2 = {
    enable = true;
    configFile = "/etc/nixos/config/dovecot.conf";
  };

  # passdb file for dovecot
  environment.etc."dovecot/passwd".source = "/etc/nixos/config/passwd";

  services.upower.enable = true;

  services.cron.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
  system.autoUpgrade.enable = true;
}
