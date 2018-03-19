# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  cifs_automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
in {
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
  boot.kernelPackages = pkgs.linuxPackages_4_14;

  boot.zfs = {
    forceImportAll = false;
    forceImportRoot = false;
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    acpi
    aspell
    aspellDicts.en
    blktrace
    cifs-utils
    cowsay
    chromiumBeta
    davfs2
    direnv
    dmenu
    docker-gc
    espeak
    ethtool
    exfat
    ffmpeg
    fira-code
    ghostscript
    git
    gnome2.gtk
    gnome3.gtk # add explicitly so that things get linked
    gnupg
    hdparm
    hfsprogs
    htop
    hwloc
    imagemagick7
    iotop
    isync
    jq
    libu2f-host
    lshw
    lsof
    maim
    mpc_cli
    mpd
    msmtp
    nethogs
    openssl
    p7zip
    pass
    pciutils
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
    termite
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
    wirelesstools
    xautolock
    xbindkeys
    xorg.xbacklight
    xorg.xev
    xorg.xmodmap
    xsel
    zathura
    zip
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  programs.bcc.enable = true;
  programs.command-not-found.enable = true;
  programs.chromium = {
    enable = true;
    extensions = [
      "naepdomgkenhinolocfifgehidddafch" # browserpass-ce
      "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    ];
    defaultSearchProviderSearchURL = "https://duckduckgo.com/?q=%s";
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
      emojione
    ];
  };

  programs.bash.enableCompletion = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;

    libinput = {
      enable = true;
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

  users.groups = { u2f = {}; usb = {}; davfs2 = {}; };
  users.users.davfs2 = {
    isSystemUser = true;
    group = "davfs2";
  };

  users.users.shosti = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "usb" "u2f" "libvirtd" "systemd-journal" "docker" "dialout" "wireshark" "media" "davfs2" ];
  };

  virtualisation.libvirtd.enable = true;
  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

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
    package = pkgs.emacs.override {
      withGTK2 = false;
      withGTK3 = false;
      imagemagick = pkgs.imagemagick;
    };
    defaultEditor = true;
  };

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "daily";
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

  # Fix yubikey and USB permissions
  services.udev.extraRules = ''
    ACTION!="add|change", GOTO="u2f_end"

    # Yubico YubiKey
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", GROUP="u2f"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", GROUP="u2f"

    LABEL="u2f_end"

    SUBSYSTEM=="usb", ATTR{removable}=="removable", GROUP="usb"
  '';

  services.zerotierone.enable = true;
  networking.firewall.allowedUDPPorts = [ 9993 ]; # zerotier likes that port

  # Some ngnix stuff for work...
  networking.extraHosts = ''
    127.0.0.1 app.rainforest.test
    127.0.0.1 admin.rainforest.test
    127.0.0.1 portal.rainforest.test
    127.0.0.1 automation.rainforest.test

    # Zerotier machines
    172.23.129.187 oldtown
  '';

  services.nginx.virtualHosts = {
    "app.rainforest.test" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };

    "admin.rainforest.test" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };

    "portal.rainforest.test" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };

    "automation.rainforest.test" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
      };
    };
  };

  users.groups.media = {};

  fileSystems."/mnt/share" = {
    device = "//oldtown/shosti";
    fsType = "cifs";
    options = ["${cifs_automount_opts},credentials=/etc/nixos/smb-secrets,uid=shosti,gid=users"];
  };

  fileSystems."/mnt/media" = {
    device = "//oldtown/media";
    fsType = "cifs";
    options = ["${cifs_automount_opts},credentials=/etc/nixos/smb-secrets,uid=shosti,gid=media"];
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/media/Media/Music";
    group = "media";
  };

  services.nginx.recommendedProxySettings = true;
  services.nginx.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";
}
