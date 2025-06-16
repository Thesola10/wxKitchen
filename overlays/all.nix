self: super: {
  wxWidgets = self.callPackage ../packages/wxWidgets {};
  wxc = self.callPackage ../packages/wxc {};
  cryanc = self.callPackage ../packages/cryanc {};
  curling = self.callPackage ../packages/curling {};

  buildWxApp = self.callPackage ../buildWxApp.nix {};

  wxkitchen-c-demo = self.callPackage ../demos/cdemo {};
  wxkitchen-demo = self.callPackage ../demos/demo {};
  wxkitchen-c-demo-tls = self.callPackage ../demos/cdemo-tls {};
}
