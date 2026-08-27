set default-list := true

[windows]
set shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

scad := "tamagotchi-paradise-uart-adaptor.scad"

# Verify that OpenSCAD is available
check:
    openscad --version

# Generate the printable adapter STL
adapter:
    openscad -D part=0 -D show_board_preview=false -D show_pin_preview=false -o adapter.stl {{scad}}

# Generate the printable lid STL
lid:
    openscad -D part=1 -D show_board_preview=false -D show_pin_preview=false -o lid.stl {{scad}}

# Generate both printable STLs
print: adapter lid

# Generate the open-lid preview with board and pogo pins
preview-open:
    openscad -D part=0 -D show_board_preview=true -D show_pin_preview=true -o docs/preview-no-lid.stl {{scad}}

# Generate the closed-lid preview with board and pogo pins
preview-closed:
    openscad -D part=2 -D show_board_preview=true -D show_pin_preview=true -o docs/preview-with-lid.stl {{scad}}

# Generate both preview STLs
preview: preview-open preview-closed

# Generate all printable and preview STLs
all: print preview
