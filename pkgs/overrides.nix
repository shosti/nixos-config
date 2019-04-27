{ config, pkgs, ... }:

{
  nixpkgs.config = {
    packageOverrides = super: let self = super.pkgs; in {
      # Bring in master version of networkmanager for wireguard support
      networkmanager = super.networkmanager.overrideAttrs (oldAttrs: rec {
        version = "1.16.0";
        name = "network-manager-${version}";
        pname = "NetworkManager";

        src = pkgs.fetchurl {
          url = "mirror://gnome/sources/${pname}/${pkgs.stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
          sha256 = "0b2x9hrg41cd17psqi0vacwj733v99hxczn53gdfs0yanqrji5lf";
        };


        installFlags = [
          "sysconfdir=${placeholder "out"}/etc"
          "localstatedir=${placeholder "out"}/var"
          "runstatedir=${placeholder "out"}/run"
        ];

        postInstall = ''
          mkdir -p $out/lib/NetworkManager

          # FIXME: Workaround until NixOS' dbus+systemd supports at_console policy
          substituteInPlace $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf --replace 'at_console="true"' 'group="networkmanager"'

          # systemd in NixOS doesn't use `systemctl enable`, so we need to establish
          # aliases ourselves.
          ln -s $out/etc/systemd/system/NetworkManager-dispatcher.service $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
          ln -s $out/etc/systemd/system/NetworkManager.service $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service

          # Add the legacy service name from before #51382 to prevent NetworkManager
          # from not starting back up:
          # TODO: remove this once 19.10 is released
          ln -s $out/etc/systemd/system/NetworkManager.service $out/etc/systemd/system/network-manager.service
        '';

        patches = with super.pkgs; [
          (substituteAll {
            src = ./nm-fix-paths.patch;
            inherit inetutils kmod openconnect ethtool coreutils dbus;
            inherit (stdenv) shell;
          })

        ];
      });
    };
  };
}
