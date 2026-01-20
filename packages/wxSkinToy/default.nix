{
  stdenv,
  lib,
  wxWidgets,
  cmake,
  fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "wxSkin";
  version = "unstable-20110830";

  src = fetchFromGitHub {
    repo = "wxskintoy";
    owner = "EEmmanuel7";
    rev = "master";
    hash = "sha256-q3oh2qFCYv0TDoLtqnyxUN7tzjR6QygvAGmUrJoUMrU=";
  };

  nativeBuildInputs =
    [
      cmake
    ];

  propagatedBuildInputs =
    [
      wxWidgets
    ];

  cmakeFlags = [
    "--trace-expand"
  ];

  WXWIN = "${wxWidgets}";

  meta = with lib; {
    homepage = "https://github.com/EEmmanuel7/wxskintoy";
    description = "wxSkin is a simple set of addon controls that allow easy creation of skinned applications.";
    license = licenses.wxWindows;
    badPlatforms = [
      wxWidgets.withUniversal
    ];
  };
}
