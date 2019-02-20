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
  boot.supportedFilesystems = [ "zfs" "nfs4" ];
  boot.tmpOnTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_4_19;

  # Disable hibernate resume, since it doesn't work and slows down the boot
  # process
  boot.resumeDevice = "/dev/null";

  boot.zfs = {
    forceImportAll = false;
    forceImportRoot = false;
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    acpi
    alsaUtils
    aspell
    aspellDicts.en
    chromium
    cowsay
    direnv
    dmenu
    docker-gc
    ethtool
    exfat
    feh
    ffmpeg
    file
    gitFull
    gnome2.gtk
    gnome3.gtk # add explicitly so that things get linked
    gnupg
    htop
    iotop
    isync
    jq
    ldns # for drill
    libu2f-host
    lsof
    maim
    mpc_cli
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

  # Chromium stuff
  programs.browserpass.enable = true;
  programs.chromium = {
    enable = true;
    defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    extensions = [
      "naepdomgkenhinolocfifgehidddafch" # browserpass-ce
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
    extraOpts = {
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "DuckDuckGo";
      PasswordManagerEnabled = false;
      BrowserSignin = 0;
      AudioCaptureAllowed = false;
      RestoreOnStartup = 5;
      NetworkPredictionOptions = 2;
      SafeBrowsingEnabled = true;
      SafeBrowsingExtendedReportingEnabled = false;
      SearchSuggestEnabled = false;
    };
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      fira-code
      (import ./pkgs/droid-slashed.nix)
      noto-fonts
      noto-fonts-emoji
      symbola
      emojione
    ];
  };

  sound.enable = true;

  programs.bash.enableCompletion = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.slim.enable = true;

    libinput = {
      enable = true;
    };
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

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

  users.groups = { u2f = { gid = 491; }; usb = {}; davfs2 = {}; };
  users.users.davfs2 = {
    isSystemUser = true;
    group = "davfs2";
  };

  users.users.shosti = {
    isNormalUser = true;
    extraGroups = [
      "davfs2"
      "dialout"
      "docker"
      "dovecot"
      "libvirtd"
      "media"
      "networkmanager"
      "sway"
      "systemd-journal"
      "u2f"
      "usb"
      "wheel"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBwhzPdTwHKLdFXmOIBP58nO0u+iQVb98jH+BLYiG7VINuQ7SF3dB/odVbyxj3DWZxm99gRW5ofvkLSlqA96uLSsJnsJ7QkJNwEDrHK00W9TRdBHHwjivR4BPLcWyp6why0tmabJSNl171y4dm60I7xQ/sKRzr7mowkIXGTIn6ohgUwNOUFPSQGJXYQxVtAUFyFOIEg8jepY+vy2rOl/VdTZccI/4YjTgISf/OTRlvbS+WBAwMUi7j7oSvYjCgR4Ql68BDp6FCgTmyHkYlwszVCsvDDgGnC7h2z6oRgHBgP8nlSSOhNwSmJfUMZ162mFlyoTX6EcbPn0O7dkzvScZO0CdTM5hWrx6X/lnSvvnZcsnA+fqqwt0qpAiZ3HXAeZtxBCaPwmbepqMII+3zXyFXDtF6h8083yOAsnW3o0GKm/nN31SLSpXaDpogjrZo6E5Q0NESPaoad3+cDX+D/Ohz51+9VbFyr9Uf2g8yCHif+9VQy3PW8kFfjJ0H2cPci0ECcNjw4RDjNEg0X3jyY1tDpCcdSJnTZP0YYTEE1TtBVB4afSjXauL7dL5X58jLjixinekjvUDUb01hoI5An/xst+lHUxGVxHUQjkkGahxKMFO6X37V0Cxk63PnaGHvljAGO9TiqdtxFwo9+mjspydVOUneRt/Yw0oQWndtjS8jew== openpgp:0x36C47065"
    ];
  };

  virtualisation.libvirtd.enable = true;
  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
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
      system.stateVersion = "18.03";
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
    package = pkgs.callPackage ./emacs.nix {};
    defaultEditor = true;
  };

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
  };

  users.groups.dovecot = {};

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
  networking.firewall.interfaces = {
    default = {
      allowedUDPPorts = [ 9993 ]; # zerotier likes that port
    };
    ztyqbxhcwp = {
      allowedTCPPorts = [
        22 # ssh
        6600 # mpd
      ];
    };
  };
  networking.firewall.trustedInterfaces = [ "virbr0" "virbr2" ]; # for kvm
  networking.domain = "emanuel.industries";

  # Some ngnix stuff for work...
  networking.extraHosts = builtins.readFile ./facebook-hosts + builtins.readFile ./extra-hosts;

  services.nginx.virtualHosts = {
    "app.rainforest.test" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8002";
        extraConfig = ''
          proxy_pass_request_headers on;
        '';
      };
      extraConfig = ''
        underscores_in_headers on;
      '';
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

  users.groups.media = {
    gid = 499;
  };

  # Can't enable the krb5 module because we *don't* want pam_krb5 (everything it
  # seems to hang indeterminately if the kdc is down)
  krb5 = {
    enable = true;
    realms = {
      "EMANUEL.INDUSTRIES" = {
        kdc = "kdc.emanuel.industries";
        admin_server = "kdc.emanuel.industries";
      };
    };
    libdefaults.default_realm = "EMANUEL.INDUSTRIES";
    kerberos = pkgs.heimdalFull;
    domain_realm = {
      "emanuel.industries" = "EMANUEL.INDUSTRIES";
      ".emanuel.industries" = "EMANUEL.INDUSTRIES";
    };
  };

  environment.etc."krb5.keytab" = {
    source = "/etc/nixos/krb5.keytab";
  };


  fileSystems."/mnt/share" = {
    device = "oldtown.emanuel.industries:/storage/shares/shosti";
    fsType = "nfs4";
    options = [ "noauto" "x-systemd.automount" ];
  };

  fileSystems."/mnt/media" = {
    device = "oldtown.emanuel.industries:/storage/shares/media";
    fsType = "nfs4";
    options = [ "sec=sys" "noauto" "x-systemd.automount" ];
  };

  containers.mpd = {
    autoStart = true;
    bindMounts."/music" = {
      hostPath = "/mnt/media/Media/Music";
      isReadOnly = true;
    };
    bindMounts."/dev/snd" = {
      hostPath = "/dev/snd";
      isReadOnly = false;
    };
    allowedDevices = [
      { modifier = "rw"; node = "char-alsa"; }
    ];

    config = { config, pkgs, ... }: {
      users.groups.media = {
        gid = 499;
      };
      sound.enable = true;

      users.users.mpd = {
        isNormalUser = false;
        extraGroups = ["media"];
      };

      services.mpd = {
        enable = true;
        musicDirectory = "/music";

        user = "mpd";
        group = "media";
        network.listenAddress = "any";
      };
    };
  };

  services.nginx.recommendedProxySettings = true;
  services.nginx.enable = true;

  security.pki.certificates = [
    ''
      Emanuel Industries Internal CA
      -----BEGIN CERTIFICATE-----
      MIIGMDCCBBigAwIBAgIJAOF8mCLrtttcMA0GCSqGSIb3DQEBCwUAMIGkMQswCQYD
      VQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5j
      aXNjbzEbMBkGA1UECgwSRW1hbnVlbCBJbmR1c3RyaWVzMSMwIQYDVQQDDBpFbWFu
      dWVsIEluZHVzdHJpZXMgUm9vdCBDQTEmMCQGCSqGSIb3DQEJARYXcm9vdEBlbWFu
      dWVsLmluZHVzdHJpZXMwHhcNMTgwMjExMjM1MDEwWhcNMzgwMjA2MjM1MDEwWjCB
      pDELMAkGA1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNh
      biBGcmFuY2lzY28xGzAZBgNVBAoMEkVtYW51ZWwgSW5kdXN0cmllczEjMCEGA1UE
      AwwaRW1hbnVlbCBJbmR1c3RyaWVzIFJvb3QgQ0ExJjAkBgkqhkiG9w0BCQEWF3Jv
      b3RAZW1hbnVlbC5pbmR1c3RyaWVzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
      CgKCAgEAzv6RKCkqKW2cCiwZ0OdKHd+rtiXk++MYKPHro42i+iE+tKa5hKkV8ZY5
      PT+om17dQ/lMB2nbd3PYl1iW09x0m9ew1o8kjHUaWcR1I+20XLA01bS0LL03cGCz
      HbywcPdKkFKSHZS8OxAheOTTWwR0TzwCivmDFhPqQ8O1CSjyEcHTC/9TfwNx1AeE
      Ag7R6q/gHS0NZHPgW2aQXFH+HV4YpyD8rTepszNnU1AGrDsjgmbp9xQuHJRv2OWj
      s0amAhl62RF3gR6DCM4w6dTFP4wS+sOlz4g8EMMLkfKj6FmJ+BIRTBrx9jwnDXCX
      Emmoi6mHYSrdfSQWk9S8YFPldzBI7nEI4FR1cAdGC5dkqCjSL8R98BXj6m4LOvU8
      OrFGIznxdfq8chtj9hkponYp4/64+qrSA7u9F3/yEnsmImwtzH6rK+6sGtC9EzbP
      4dA1XrlPs2t2djYjmUDVtYVJtG0wCyZeW41OQhPppas8Pkzo9VSxXt9f9MYi5iBu
      IodYP/01I+dTxnukCOjyWVHp+XDO5zGi0NYbA8xamsb0Hv/LeCnwioj4ItzHS7yh
      T4/iebSoY1AjzPOj6HPQTC63vHqx2HNYbmOuC0L4xnAmTZ8KC4dmqhVo05IUXxwS
      Qg35eNulRhKeVtERZRkVVXVGbmC1dhCe3aLUbjoyTM1HHYwE12UCAwEAAaNjMGEw
      HQYDVR0OBBYEFI31S1c/ltBggsws2msyeW2Uv4ltMB8GA1UdIwQYMBaAFI31S1c/
      ltBggsws2msyeW2Uv4ltMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGG
      MA0GCSqGSIb3DQEBCwUAA4ICAQBzowymtxcI8XM1zFTKxNxFBdnuG+xSRW1UyMD6
      KLzlB4q5VHiLFrblQh4lQp7qQ96TbQJKuikoM0fqKFNmOkFfkSsXVqdxVRDZNReW
      08QJAMdYOsigFKN7my9roKgZqfTw8sbjBS7AgMdex+f1scVtZYw39YKiEXDjqGQU
      mLqOtgdeCseItG5fhsKsE5iWVTmc2ItLUmkXAyGVYjQNQZHQssJBdNzmC8WunOZ4
      tk8fepBjYnnvH7xUD+v6AuLbrUu2Gr9I0dEuk2B+RYZMpOT+r4cXP9dOaR0Knktb
      onm/2IhDk3LUL1Wgx9HTn6z3HmSZ6XCeBFjb7Mf3C1gsZXW0M2lChF0EM4dYUHV1
      ACozMbubFB4lFtIQZexAGF3vZfum8qxjTzY+ChPY2g6qQ8XRBwypS52I0qt8Sf0s
      6iSU+PKeAPNIjpQsTr/IjEahfBt80tNtEwYLDVKSq+WhPox9ouQBlvW3WtUzGIxP
      PBw+pNkSsKcQUsR/DWHOIvNGKcpBQCipcorh5OK1/iiUXxLG+lcGPmUFZw4Osbr+
      3S4GUvBb3EGRixyp7HfKGm6/96HoSPxzhVWKwvuxvZv5LFlusldPkENx2dt2rqnV
      ET3sOSkAKYakJ9y5Iv6GytnTdOxN+jpBBkXXU0UrUIY+jfCPZ9j3jjPHEzioNrCC
      zUQiCA==
      -----END CERTIFICATE-----
    ''
  ];


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";
}
