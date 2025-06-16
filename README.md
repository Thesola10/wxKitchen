# wxKitchen

wxKitchen is a Nix flake intended to facilitate cross-compiling apps written with [wxWidgets] 2.6, to make it as easy as possible to write apps for old operating systems!

## Supported targets
- Windows 98 and later (`pkgsCross.i686-mingw32`)
- Mac OS 8 and later on PowerPC with Carbon (`pkgsCross.ppc-macos`)¹
- Linux 2.4 and later with GTK+ (`pkgsCross.i686-linux24`) _(in progress)_
- Palm OS _(planned)_

¹ _Functions `mkdir`, `rmdir`, `getcwd` and `chdir` have been removed from Mac OS builds pending a better solution._

You are free to try building for your host system, to aid with debugging.

## Getting started
You can start by building the example projects provided.

For example, to build the Windows demo, use the command below:

```sh
nix build github:thesola10/wxKitchen#demo-i686-mingw32
```

[wxWidgets]: https://wxwidgets.org
