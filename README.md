# Tamagotchi Paradise UART Adaptor

![cc-by-nc-sa-shield](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)

## Install OpenSCAD

This project use OpenSCAD script to model the adaptor

```bash
# Windows
winget install -e --id OpenSCAD.OpenSCAD

# MacOS
brew install --cask openscad@snapshot
```

## Install just

```bash
# Windows
winget install -e --id Casey.Just

# MacOS
brew install just
```

## Generate .stl for 3D printing

Generate the printable adapter and lid:

```bash
just print
```

Generate an individual part with `just adapter` or `just lid`. Generate all printable and preview files with:

```bash
just all
```

## Preview

[Adapter](./adapter.stl) · [Lid](./lid.stl) · [Removed Lid with board & pin](./docs/preview-no-lid.stl) · [Closed Lid with board & pin](./docs/preview-with-lid.stl)

```bash
just preview
```

## Components

### 1. FTL232RL USB to ttl module (USB Type-C)

![ftl232rl-module](./docs/ftl232rl-module.png)  
[Example Retail](https://item.taobao.com/item.htm?from=detail&id=977654905255&mi_id=0000h-JgSDiB4f7Ho-2niVD6hPhUYCVJkwAm0X3ns97yCBI&spm=tbpc.orderdetail.suborder_itemtitle.1.1ac16aa62cI0VB)

🚨🚨🚨 __Tamagotchi Paradise only accept 3.3v for signal, please check your usb to ttl TX is output 3.3v otherwise it can damage your Tamagotchi Paradise device!!!__ 🚨🚨🚨

Requirement:
- Tamagotchi Paradise require input signal with 3.3v, otherwise the command will failed / damage your tamagotchi device
- Baud rate need to support 460800

### 2. Pogo pins

It used for contact the top portion of the physical connector pins from Tamagotchi Paradise device. Notices that the size does matter.
Here I use A-SMT pin, (flat flange, no tail) with following spec:

```
Ø3 × 0.5 mm flange
Ø2 × 7.0 mm barrel
Ø1.5 × 2.5 mm plunger
10 mm overall.
```

![pogopin](./docs/pin.png)  
[Example Retail](https://item.taobao.com/item.htm?id=836549063705&mi_id=0000gXqq91Ah3jaaENDyuLehYernuiv4zQMBeJ2WHqH3nCw&spm=tbpc.boughtlist.suborder_itempic.d836549063705.62082e8dhEZmYZ)

### 3. Wire for soldering

Any wire (suggest to use 24 AWG) for soldering TX, RX, GND to the pogo pins.

## Connection Scheme

Soldering the pin reference to the following scheme, the left side of the adaptor plug your own USB type-c cable to your PC.

![connection-scheme](./docs/connection-scheme.png)

## Special Thanks

This project reference and modified from hook model `./reference-stl/Basic_rev2.stl` [IgelFullmetal](https://www.thingiverse.com/thing:7310297) Creative Common License
