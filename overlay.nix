self: super: {

  wxWidgets = super.callPackage ./packages/wxWidgets {};

  wxc = self.callPackage ./packages/wxc {};

  buildWxApp = self.callPackage ./buildWxApp.nix {};

  wxkitchen-demo = self.callPackage ./packages/demo {};
}
