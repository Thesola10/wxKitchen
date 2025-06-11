self: super: {
  wxWidgets = self.callPackage ../packages/wxWidgets {};
  wxc = self.callPackage ../packages/wxc {};

  buildWxApp = self.callPackage ../buildWxApp.nix {};

  wxkitchen-c-demo = self.callPackage ../packages/cdemo {};
  wxkitchen-demo = self.callPackage ../packages/demo {};
}
