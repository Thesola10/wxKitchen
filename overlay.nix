self: super: {

  lib = super.lib // {
    buildWxApp = self.callPackage ./buildWxApp.nix;
  };
}
