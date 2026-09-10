set default-list := true

[windows]
set shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

wire_scad := "models/wire/wire-adaptor.scad"
wireless_battery_scad := "models/wireless/wireless-3a-battery.scad"

# Verify that OpenSCAD is available
check:
    openscad --version

# Generate the existing wired adapter and lid
wire:
    openscad -D part=0 -D show_board_preview=false -D show_pin_preview=false -o models/wire/wire-adaptor.stl {{wire_scad}}
    openscad -D part=1 -D show_board_preview=false -D show_pin_preview=false -o models/wire/wire-lid.stl {{wire_scad}}

# Generate the two-cell AAA battery holder for the wireless adaptor
wireless-3a-battery:
    openscad -o models/wireless/wireless-3a-battery.stl {{wireless_battery_scad}}

# Generate every printable model
all: wire wireless-3a-battery
