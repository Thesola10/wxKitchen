# wxKitchen

wxKitchen is a Nix flake intended to facilitate cross-compiling apps written with [wxWidgets] 2.6, to make it as easy as possible to write apps for old operating systems!

## Supported targets
- Windows NT 4 and later (`pkgsCross.i686-mingw32`)
- Mac OS 9 with Carbon (`pkgsCross.ppc-macos`) _(work in progress)_
- Palm OS _(planned)_
- Linux 2.4 with GTK+ _(planned)_

## Getting started
You can start by building the example projects provided.

For example, to build the Windows demo, use the command below:

```sh
nix build github:thesola10/wxKitchen#demo-i686-mingw32
```

[wxWidgets]: https://wxwidgets.org
