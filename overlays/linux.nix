self: super: {
  gtk2 = (super.gtk2.override {
    cupsSupport = false;
    xineramaSupport = false;
    gobject-introspection = super.emptyDirectory;
  }).overrideAttrs (prev: {
    configureFlags = prev.configureFlags ++ [
      "--disable-introspection"
    ];
  });

  # Meson assumes systemd and introspection are available -- they are not.
  atk = super.atk.overrideAttrs (prev:{
    mesonFlags = [
      "-Ddbus_daemon=/usr/bin/dbus-daemon"
      "-Duse_systemd=false"
      "-Dintrospection=disabled"
    ];
  });

  libjpeg = super.libjpeg_original;

  lib = if super.stdenv.hostPlatform.isMusl then
    super.lib // {
    meta = super.lib.meta // {
      availableOn = a: b:
        let
          unavailablePackages = [
            # Static builds do not support introdpection
            "gobject-introspection"
            "gobject-introspection-wrapped"

            # The past is another country, they do things differently.
            "systemd"
          ];
          unavailable = elem:
            builtins.foldl' (l: r: l || (r == elem.pname)) false unavailablePackages;
        in
        if unavailable b
          then false
          else super.lib.meta.availableOn a b;
    };
  } else super.lib;
}
