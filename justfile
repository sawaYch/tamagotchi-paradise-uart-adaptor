set default-list := true

[windows]
set shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

# Verify that build123d is available
check:
    uv run python -c "import build123d; print(build123d.__version__)"

# Generate the wired adapter and lid
wire:
    uv run python -m adaptor wire

# Generate the wireless adapter and magnetic lid
wireless:
    uv run python -m adaptor wireless

# Generate every printable model
all: wire wireless
