{
  arm = {
    system = "arm-palmos";
    config = "arm-palmos";
    libc = null;
    parsed = {
      cpu = {
        name = "arm";
        bits = 32;
        significantByte = { name = "littleEndian"; };
        family = "arm";
      };
      kernel = {
        name = "palmos";
        execFormat = { name = "unknown"; };
      };
      vendor = { name = "unknown"; };
      abi = { name = "palm"; float = "soft"; };
    };
    isStatic = true;

    isPalm = true;
  };

  m68k = {
    system = "m68k-palmos";
    config = "m68k-palmos";
    libc = null;
    parsed = {
      cpu = {
        name = "m68k";
        bits = 32;
        significantByte = { name = "bigEndian"; };
        family = "m68k";
      };
      kernel = {
        name = "palmos";
        execFormat = { name = "unknown"; };
      };
      vendor = { name = "unknown"; };
      abi = { name = "palm"; };
    };
    isStatic = true;

    isPalm = true;
  };
}
