self: super: {
  wxWidgets = self.callPackage ../packages/common/wxWidgets {};
  wxc = self.callPackage ../packages/common/wxc {};
  cryanc = self.callPackage ../packages/common/cryanc {};
  curling = self.callPackage ../packages/common/curling {};

  buildWxApp = self.callPackage ../buildWxApp.nix {};

  wxkitchen-c-demo = self.callPackage ../demos/cdemo {};
  wxkitchen-demo = self.callPackage ../demos/demo {};
  wxkitchen-c-demo-tls = self.callPackage ../demos/cdemo-tls {};
}
