{
  stdenv,
  lib,
  wxWidgets,
  wxc,
  retro68 ? null
}:

{
  buildInputs ? [],
  nativeBuildInputs ? [],
  postInstall ? "",

  # Whether to link against the wxc C bindings library for wxWidgets.
  withWxc ? false,

  # In kilobytes, the size of the two predefined heap blocks.
  # Mac Classic apps need to specify their heap size in advance, so
  # try increasing this if your app crashes on Mac OS 9 but not OS X.
  reservedMemoryMacOS ? 2048,
  ...
}@args:

stdenv.mkDerivation (args // {
  hardeningDisable = [ "all" ];

  buildInputs = [
    wxWidgets
  ] ++ lib.optionals withWxc [
    wxc
  ] ++ buildInputs;

  nativeBuildInputs = lib.optionals (stdenv.hostPlatform ? retro68) [
    retro68.tools
  ] ++ nativeBuildInputs;

  postInstall = lib.optionalString (stdenv.hostPlatform ? retro68) ''
    for file in $out/bin/*
    do
      MakePEF $file -o $file.pef
      Rez -I ${retro68.universal}/RIncludes \
          ${retro68.libretro}/RIncludes/RetroCarbonAPPL.r \
          --copy ${wxWidgets}/lib/libwx_base_carbon.bin \
          -DMEMORY_RESERVED_KB=${toString reservedMemoryMacOS} \
          -DCFRAG_NAME="\"$(basename $file)\"" --data $file.pef \
          -o $file.bin -t APPL -c ro68
    done
  '' + postInstall;

  NIX_CFLAGS_COMPILE = (lib.readFile "${wxWidgets}/nix-support/cc-cflags")
                     + lib.optionalString withWxc "-I${wxc}/include";
  NIX_CXXFLAGS_COMPILE = lib.readFile "${wxWidgets}/nix-support/libcxx-cxxflags";
  NIX_CFLAGS_LINK = lib.optionalString withWxc "-L${wxc}/lib -lwxc "
                  + (lib.readFile "${wxWidgets}/nix-support/cc-ldflags")
                  + " -lstdc++";
})
