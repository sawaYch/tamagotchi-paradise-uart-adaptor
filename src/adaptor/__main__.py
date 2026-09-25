"""Export printable adaptor STLs."""

from __future__ import annotations

import argparse
import sys

from build123d import export_stl

from adaptor.shared import ROOT

PARTS = {
    "wire": (
        ("adaptor.wire", "adapter", ROOT / "models" / "wire" / "wire-adaptor.stl"),
        ("adaptor.wire", "lid", ROOT / "models" / "wire" / "wire-lid.stl"),
    ),
    "wireless": (
        ("adaptor.wireless", "adapter", ROOT / "models" / "wireless" / "wireless-adaptor.stl"),
        ("adaptor.wireless", "lid", ROOT / "models" / "wireless" / "wireless-lid.stl"),
    ),
}


def _build(module_name: str, fn_name: str):
    import importlib

    module = importlib.import_module(module_name)
    shape = getattr(module, fn_name)()
    if not shape.is_valid:
        raise RuntimeError(f"{module_name}.{fn_name} produced an invalid solid")
    solids = shape.solids()
    if len(solids) != 1:
        raise RuntimeError(f"{module_name}.{fn_name} has {len(solids)} solids")
    return shape


def export_named(name: str) -> None:
    for module_name, fn_name, path in PARTS[name]:
        print(f"building {path.name}...", file=sys.stderr)
        shape = _build(module_name, fn_name)
        path.parent.mkdir(parents=True, exist_ok=True)
        export_stl(shape, path, tolerance=0.01, angular_tolerance=0.1)
        box = shape.bounding_box()
        print(
            f"wrote {path.relative_to(ROOT)} "
            f"size=({box.size.X:.2f}, {box.size.Y:.2f}, {box.size.Z:.2f}) "
            f"volume={shape.volume:.1f}",
            file=sys.stderr,
        )


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Export Tamagotchi Paradise adaptor STLs")
    parser.add_argument("part", choices=["wire", "wireless", "all"])
    args = parser.parse_args(argv)
    names = ["wire", "wireless"] if args.part == "all" else [args.part]
    for name in names:
        export_named(name)


if __name__ == "__main__":
    main()
