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
    acpi
    aspell
    aspellDicts.en
    blktrace
    chromium
    cowsay
    direnv
    dmenu
    emacs25
    espeak
    ethtool
    exfat
    ffmpeg
    ghostscript
    git
    gnome2.gtk
    gnome3.gtk # add explicitly so that things get linked
    gnupg
    hdparm
    hfsprogs
    htop
    hwloc
    i3lock
    imagemagick7
    iotop
    isync
    jq
    libu2f-host
    lshw
    lsof
    maim
    msmtp
    nethogs
    openssl
    p7zip
    pass
    pcsctools
    pinentry
    postgresql96 # for psql
    powertop
    psmisc
    pv
    pwgen
    redis # for redis-cli
    rfkill
    rxvt_unicode-with-plugins
    silver-searcher
    sl
    slop
    stow
    syncthing
    sysstat
    telnet
    traceroute
    tree
    unzip
    usbutils
    vim
    virtmanager
    virt-viewer
    vlc
    wget
    whois
    ykpers
    yubikey-neo-manager
    yubioath-desktop
    xautolock
    xbindkeys
    xorg.xbacklight
    xorg.xev
    xorg.xmodmap
    xsel
    zathura
    zip
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

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
  programs.ssh.startAgent = false; # Use gpg instead

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
  services.tlp = {
    enable = true;
    extraConfig = ''
      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
    '';
  };
  services.timesyncd.enable = true;
  services.locate = {
    enable = true;
    interval = "hourly";
    localuser = null;
    locate = pkgs.mlocate;
    extraFlags = [ "-n '.git .backups .Trash .mail .cache vendor'" ];
  };
  services.redshift = {
    enable = true;
    latitude = "37.7618";
    longitude = "-122.4856";
  };

  hardware.bluetooth.enable = false;
  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
  };

  users.groups = { u2f = {}; };

  users.users.shosti = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "u2f" "libvirtd" "systemd-journal" "docker" ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

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

  # Hack to get rid of annoying warning message
  environment.variables.NO_AT_BRIDGE = "1";

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
    createMailUser = false;
  };

  # passdb file for dovecot
  environment.etc."dovecot/passwd".source = "/etc/nixos/config/passwd";

  services.upower.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.brgenml1cupswrapper ];
  };
  services.cron.enable = true;
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  security.sudo.wheelNeedsPassword = false;
  security.pam.loginLimits = [
    {
      domain = "shosti";
      type = "hard";
      item = "nofile";
      value = "262144"; # seems like a nice round number...
    }

    {
      domain = "shosti";
      type = "soft";
      item = "nofile";
      value = "262144";
    }
  ];

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

  services.pcscd.enable = true;

  # Fix yubikey permissions
  services.udev.extraRules = ''
    ACTION!="add|change", GOTO="u2f_end"

    # Yubico YubiKey
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", GROUP="u2f"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", GROUP="u2f"

    LABEL="u2f_end"
  '';

  # Some ngnix stuff for work...
  networking.extraHosts = ''
    127.0.0.1 app.rainforest.dev
    127.0.0.1 admin.rainforest.dev
    127.0.0.1 portal.rainforest.dev
    127.0.0.1 automation.rainforest.dev
  '';

  services.nginx.virtualHosts = {
    "app.rainforest.dev" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };

    "admin.rainforest.dev" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };

    "portal.rainforest.dev" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };

    "automation.rainforest.dev" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };
  };

  services.nginx.recommendedProxySettings = true;
  services.nginx.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
}
