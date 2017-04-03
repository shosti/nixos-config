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
    i3lock
    psmisc
    hwloc
    blktrace
    sysstat
    postgresql96 # for psql
    redis # for redis-cli
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

  users.users.shosti = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    # Useful for testing
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoE5MAy3Sjt3taf14lJyh6T/qe21I/VzYqgcuiaDacLTa5cRyT/+qt6wtTb3UsD6I7zTtHuzr1klshSB/5vHP7LcZkr0P398ArOFV7MSv/sR2ZPX+9bbzL5Rlewqly4Ft+COdkGeWAWk32EeXyqGbLZVWUqSagatSa2YCWuT5FAFalbVg27nlbsXhVOTi0vDd2E33shJuVwOjq+HNA48ZMZXohLaTkxB+3dWZ1XfMcuyjkS/epHUvQeBGXff/Ox8EdIVXcfDtWL41N6GgkA0v+LAiGC84bxqOuGS97t3FMGUHodVIUSLZwblhT2M4P1h7IQa0N//QmSmwabO3newZZ shosti@themountain"
    ];
  };

  virtualisation.virtualbox.host.enable = true;

  services.syncthing = {
    user = "shosti";
    enable = true;
    useInotify = true;
    dataDir = "/home/shosti/.syncthing";
  };

  containers.postgres = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql96;
        authentication = pkgs.lib.mkForce ''
          local all all trust
          host all all 127.0.0.1/32 trust
        '';
      };
    };
  };

  containers.redis = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.redis = {
        enable = true;
        bind = "127.43.224.42";
      };
    };
  };

  environment.variables.REDIS_HOST = "127.43.224.42";

  services.emacs = {
    enable = true;
    package = pkgs.emacs25;
    defaultEditor = true;
  };

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
  };

  services.dovecot2 = {
    enable = true;
    configFile = "/etc/nixos/config/dovecot.conf";
  };

  # passdb file for dovecot
  environment.etc."dovecot/passwd".source = "/etc/nixos/config/passwd";

  services.upower.enable = true;

  services.cron.enable = true;
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  security.sudo.wheelNeedsPassword = false;

  # Make sure screen is locked on suspend
  systemd.services."i3lock" = {
    enable = true;
    description = "i3lock";
    wantedBy = [ "suspend.target" "hibernate.target" ];
    before = [ "systemd-suspend.service" "systemd-hibernate.target" ];
    serviceConfig = {
      Type = "forking";
      User = "shosti"; # unfortunately necessary :(
    };
    script = "${pkgs.i3lock}/bin/i3lock";
    postStart = "${pkgs.coreutils}/bin/sleep 1";
    environment = { DISPLAY = ":0"; };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
}
