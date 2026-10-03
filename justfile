set default-list := true

[windows]
set shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

wire_scad := "models/wire/wire-adaptor.scad"
wireless_scad := "models/wireless/wireless-adaptor.scad"

# Verify that OpenSCAD is available
check:
    openscad --version

# Generate the wired adapter and magnetic lid
wire:
    openscad -D part=0 -D show_board_preview=false -D show_pin_preview=false -D show_magnet_preview=false -o models/wire/wire-adaptor.stl {{wire_scad}}
    openscad -D part=1 -D show_board_preview=false -D show_pin_preview=false -D show_magnet_preview=false -o models/wire/wire-lid.stl {{wire_scad}}

# Generate the wireless adapter, magnetic tray, and tray cover
wireless:
    openscad -D part=0 -D show_board_preview=false -D show_pin_preview=false -D show_magnet_preview=false -o models/wireless/wireless-adaptor.stl {{wireless_scad}}
    openscad -D part=1 -D show_board_preview=false -D show_pin_preview=false -D show_magnet_preview=false -o models/wireless/wireless-lid.stl {{wireless_scad}}
    openscad -D part=3 -D show_board_preview=false -D show_pin_preview=false -D show_magnet_preview=false -o models/wireless/wireless-tray-cover.stl {{wireless_scad}}

# Generate every printable model
all: wire wireless
