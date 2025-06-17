{
  stdenv,
  lib,
  wxWidgets,
  wxc,
  retro68 ? null,
  palm ? null
}:

{
  buildInputs ? [],
  nativeBuildInputs ? [],
  postInstall ? "",

  extraCFlags ? "",
  extraCXXFlags ? "",
  extraLDFlags ? "",

  pname ? "",

  # Whether to link against the wxc C bindings library for wxWidgets.
  withWxc ? false,

  # In kilobytes, the size of the two predefined heap blocks.
  # Mac Classic apps need to specify their heap size in advance, so
  # try increasing this if your app crashes on Mac OS 9 but not OS X.
  reservedMemoryMacOS ? 2048,

  # Whether to link against Retro68's console on Mac OS
  withConsoleMacOS ? false,
  ...
}@args:

let
  isRetro68 = stdenv.hostPlatform ? retro68;
  isPalmOS = stdenv.hostPlatform ? isPalm;
in stdenv.mkDerivation (args // {
  hardeningDisable = [ "all" ];

  buildInputs = [
    wxWidgets
  ] ++ lib.optionals withWxc [
    wxc
  ] ++ lib.optionals (isRetro68 && withConsoleMacOS) [
    retro68.console
  ] ++ buildInputs;

  nativeBuildInputs = lib.optionals isRetro68 [
    retro68.tools
  ] ++ nativeBuildInputs;

  postInstall = lib.optionalString isRetro68 ''
    for file in $out/bin/*
    do
      MakePEF $file -o $file.pef
      Rez -I ${retro68.universal}/RIncludes \
          ${retro68.libretro}/RIncludes/RetroCarbonAPPL.r \
          --copy ${wxWidgets}/lib/libwx_base_carbon.bin \
          -DMEMORY_RESERVED_KB=${toString reservedMemoryMacOS} \
          -DCFRAG_NAME="\"${pname}\"" --data $file.pef \
          -o $file.bin -t APPL -c ro68
    done
  '' + lib.optionalString isPalmOS ''
    for file in $out/bin/*
    do
      ${stdenv.hostPlatform.config}-obj-res $file
      build-prc $file.prc "${pname}" WXKI *.$file.grc
    done
  '' + postInstall;

  NIX_CFLAGS_COMPILE = (lib.readFile "${wxWidgets}/nix-support/cc-cflags")
                     + lib.optionalString withWxc "-I${wxc}/include "
                     + extraCFlags;
  NIX_CXXFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/libcxx-cxxflags"
                       + extraCXXFlags;
  NIX_CFLAGS_LINK = extraLDFlags
                  + lib.optionalString withWxc " -L${wxc}/lib -lwxc "
                  + (lib.readFile "${wxWidgets}/nix-support/cc-ldflags")
                  + lib.optionalString (isRetro68 && withConsoleMacOS)
                      " -L${retro68.console} -lRetroConsoleCarbon"
                  + " -lstdc++";
})
