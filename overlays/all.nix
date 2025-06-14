self: super: {
  wxWidgets = self.callPackage ../packages/wxWidgets {};
  wxc = self.callPackage ../packages/wxc {};
  cryanc = self.callPackage ../packages/cryanc {};

  buildWxApp = self.callPackage ../buildWxApp.nix {};

  wxkitchen-c-demo = self.callPackage ../packages/cdemo {};
  wxkitchen-demo = self.callPackage ../packages/demo {};
  wxkitchen-c-demo-tls = self.callPackage ../packages/cdemo-tls {};
}
