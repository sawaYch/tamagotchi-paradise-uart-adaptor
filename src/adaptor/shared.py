"""Hook, pogo pins, and shell geometry shared by both adaptors."""

from __future__ import annotations

import sys
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from build123d import (
    Align,
    Box,
    Cone,
    Cylinder,
    Mesher,
    Polygon,
    Pos,
    RectangleRounded,
    Rot,
    Solid,
    extrude,
)

ROOT = Path(__file__).resolve().parents[2]
HOOK_STL = ROOT / "reference-stl" / "Basic_rev2.stl"

EPS = 0.05
TOLERANCE = 0.2

HOOK_L = 35.0
HOOK_W = 14.0
HOOK_H = 6.35
HOOK_R = 2.0

PIN_XS = (-12.0, 0.0, 12.0)
PIN_FLANGE_D = 3.0
PIN_FLANGE_H = 0.5
PIN_BARREL_D = 2.0
PIN_HOLE_CLEAR = 0.15
PIN_SLEEVE_OD = 3.7
PIN_SLEEVE_Z = 3.2

WALL = 1.6
WALL_INNER = WALL - 0.1
HEADROOM = 0.6
SHELL_EXTRA = 2.0

SOLDER_H = 1.0
WIRE_OD = 1.4
ISOLATOR_H = 1.0
SOLDER_WELL_H = SOLDER_H + WIRE_OD
BOARD_LIFT = SOLDER_WELL_H + ISOLATOR_H
LEDGE_W = 1.8
LEDGE_H = 1.2

PRONG_ROOT_Y = -2.5
PRONG_ROOT_W = 5.0
PRONG_ROOT_DEPTH = 3.45
PRONG_ROOT_EXTRA = 1.25
PRONG_ROOT_OVERLAP = 0.25

PRONG_GRAB_SHAVE = 0.1
PRONG_GRAB_FACE_L = -7.112
PRONG_GRAB_FACE_R = -4.888
PRONG_GRAB_Z = -2.49

GRAB_CYL_X = 6.0
GRAB_CYL_Z = -0.20
GRAB_CYL_D = 2.64
GRAB_CYL_LEN = 5.7

PIN_BARREL_HOLE = PIN_BARREL_D + 2 * PIN_HOLE_CLEAR
PIN_FLANGE_HOLE = PIN_FLANGE_D + 2 * PIN_HOLE_CLEAR

_MIN = (Align.MIN, Align.MIN, Align.MIN)
_Z_MIN = (Align.CENTER, Align.CENTER, Align.MIN)


@dataclass(frozen=True)
class ShellLayout:
    pcb_cav_l: float
    pcb_cav_w: float
    pcb_cav_h: float
    pcb_insert_x_offset: float = 0.0
    pcb_insert_y_offset: float = 0.0

    @property
    def hook_x0(self) -> float:
        return -HOOK_L / 2

    @property
    def hook_y0(self) -> float:
        return -HOOK_W / 2

    @property
    def shell_x0(self) -> float:
        return self.hook_x0

    @property
    def shell_l(self) -> float:
        return self.pcb_cav_l + 2 * WALL

    @property
    def shell_y0(self) -> float:
        return -self.pcb_cav_w / 2 - WALL

    @property
    def shell_y1(self) -> float:
        return self.pcb_cav_w / 2 + WALL

    @property
    def shell_w(self) -> float:
        return self.shell_y1 - self.shell_y0

    @property
    def shell_ox(self) -> float:
        return self.shell_x0 + self.pcb_insert_x_offset

    @property
    def shell_oy(self) -> float:
        return self.shell_y0 + self.pcb_insert_y_offset

    @property
    def shell_h(self) -> float:
        return WALL + BOARD_LIFT + self.pcb_cav_h + SHELL_EXTRA

    @property
    def pin_floor_z(self) -> float:
        return HOOK_H + WALL

    @property
    def pin_seat_z(self) -> float:
        return self.pin_floor_z - PIN_FLANGE_H

    @property
    def pcb_z(self) -> float:
        return self.pin_floor_z + BOARD_LIFT

    @property
    def ledge_z(self) -> float:
        return self.pin_floor_z + SOLDER_WELL_H - LEDGE_H


def fuse_all(shapes: list):
    result = shapes[0]
    for shape in shapes[1:]:
        result = result.fuse(shape)
    return result


def rounded_box(x: float, y: float, z: float, radius: float):
    rr = min(radius, x / 2 - 0.05, y / 2 - 0.05)
    sketch = RectangleRounded(x, y, rr, align=(Align.MIN, Align.MIN))
    return extrude(sketch, amount=z)


def cylinder_up(x: float, y: float, z: float, height: float, diameter: float):
    return Pos(x, y, z) * Cylinder(diameter / 2, height, align=_Z_MIN)


def box_at(x: float, y: float, z: float, sx: float, sy: float, sz: float):
    return Pos(x, y, z) * Box(sx, sy, sz, align=_MIN)


def convex_hull(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
    pts = sorted(set(points))
    if len(pts) <= 2:
        return pts

    def cross(o, a, b) -> float:
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower: list[tuple[float, float]] = []
    for point in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], point) <= 0:
            lower.pop()
        lower.append(point)
    upper: list[tuple[float, float]] = []
    for point in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], point) <= 0:
            upper.pop()
        upper.append(point)
    return lower[:-1] + upper[:-1]


def prism_xz(profile_xz: list[tuple[float, float]], y0: float, length: float):
    """Extrude an XZ profile along +Y, starting at y0."""
    solid = extrude(Polygon(*profile_xz), amount=length)
    return Pos(0, y0 + length, 0) * Rot(90, 0, 0) * solid


def hull_boxes_xz(box_a: tuple[float, float, float, float], box_b: tuple[float, float, float, float], y0: float, length: float):
    def corners(x0, x1, z0, z1):
        return [(x0, z0), (x1, z0), (x1, z1), (x0, z1)]

    hull = convex_hull(corners(*box_a) + corners(*box_b))
    return prism_xz(hull, y0, length)


@lru_cache(maxsize=1)
def load_hook() -> Solid:
    shapes = Mesher().read(HOOK_STL)
    if len(shapes) != 1:
        raise RuntimeError(f"expected one hook solid, got {len(shapes)}")
    hook = shapes[0]
    if not hook.is_valid:
        raise RuntimeError("imported hook is not a valid solid")
    return hook


def pcb_shell(layout: ShellLayout):
    # The shell bottom is coincident with the hook top. A mesh boolean will not
    # join those faces, so the shell overlaps the hook by a small amount.
    overlap = 0.2
    shell = Pos(layout.shell_ox, layout.shell_oy, HOOK_H - overlap) * rounded_box(
        layout.shell_l, layout.shell_w, layout.shell_h + overlap, HOOK_R
    )
    seat = Pos(layout.hook_x0, layout.hook_y0, HOOK_H - 0.5) * rounded_box(
        HOOK_L, HOOK_W, 0.5 + EPS, HOOK_R
    )
    return shell.fuse(seat)


def pcb_cavity(layout: ShellLayout):
    return Pos(layout.shell_ox + WALL_INNER, layout.shell_oy + WALL_INNER, HOOK_H + WALL) * rounded_box(
        layout.shell_l - 2 * WALL_INNER,
        layout.shell_w - 2 * WALL_INNER,
        layout.shell_h - WALL + 1,
        0.6,
    )


def pin_sleeves(layout: ShellLayout):
    height = layout.pin_floor_z - PIN_SLEEVE_Z + 0.2
    return fuse_all(
        [cylinder_up(x, 0, PIN_SLEEVE_Z, height, PIN_SLEEVE_OD) for x in PIN_XS]
    )


def pin_through_holes(layout: ShellLayout):
    holes = []
    for x in PIN_XS:
        holes.append(cylinder_up(x, 0, -1, layout.pin_floor_z + 2, PIN_BARREL_HOLE))
        holes.append(
            cylinder_up(x, 0, layout.pin_seat_z, PIN_FLANGE_H + 1, PIN_FLANGE_HOLE)
        )
        holes.append(
            Pos(x, 0, -0.2)
            * Cone(
                (PIN_BARREL_HOLE + 0.8) / 2,
                PIN_BARREL_HOLE / 2,
                1.2,
                align=_Z_MIN,
            )
        )
    return fuse_all(holes)


def prong_root_reinforcement():
    gusset_tip_w = 0.4
    gusset_root_h = 0.55
    gusset_tip_h = 0.3
    y0 = PRONG_ROOT_Y
    length = PRONG_ROOT_W

    left_root_x0 = -9.0 - PRONG_ROOT_EXTRA
    left_root = (
        left_root_x0,
        left_root_x0 + PRONG_ROOT_EXTRA + PRONG_ROOT_OVERLAP,
        -0.15,
        -0.15 + gusset_root_h,
    )
    left_tip_x0 = -9.0 - PRONG_ROOT_OVERLAP
    left_tip = (
        left_tip_x0,
        left_tip_x0 + gusset_tip_w,
        -PRONG_ROOT_DEPTH,
        -PRONG_ROOT_DEPTH + gusset_tip_h,
    )

    right_root_x0 = -3.0 - PRONG_ROOT_OVERLAP
    right_root = (
        right_root_x0,
        right_root_x0 + PRONG_ROOT_EXTRA + PRONG_ROOT_OVERLAP,
        -0.15,
        -0.15 + gusset_root_h,
    )
    right_tip_x0 = -3.0 - gusset_tip_w + PRONG_ROOT_OVERLAP
    right_tip = (
        right_tip_x0,
        right_tip_x0 + gusset_tip_w,
        -PRONG_ROOT_DEPTH,
        -PRONG_ROOT_DEPTH + gusset_tip_h,
    )
    return hull_boxes_xz(left_root, left_tip, y0, length).fuse(
        hull_boxes_xz(right_root, right_tip, y0, length)
    )


def grab_cylinder():
    return Pos(GRAB_CYL_X, -GRAB_CYL_LEN / 2, GRAB_CYL_Z) * Rot(-90, 0, 0) * Cylinder(
        GRAB_CYL_D / 2, GRAB_CYL_LEN, align=_Z_MIN
    )


def add_grab(hook):
    """Clear the original bar, then join the larger cylinder.

    A direct fuse only overlaps the imported bar by a thin shell, which the
    mesh boolean does not finish cleanly.
    """
    inset = 0.2
    notch = box_at(
        GRAB_CYL_X - 0.9,
        -GRAB_CYL_LEN / 2 + inset,
        GRAB_CYL_Z - 0.9,
        1.8,
        GRAB_CYL_LEN - 2 * inset,
        1.8,
    )
    return principal_solid(hook.cut(notch).fuse(grab_cylinder()))


def principal_solid(shape):
    solids = list(shape.solids())
    if len(solids) == 1:
        return solids[0]
    solids.sort(key=lambda solid: solid.volume, reverse=True)
    if all(abs(solid.volume) < 5 for solid in solids[1:]):
        return solids[0]
    raise RuntimeError(f"boolean left {len(solids)} solids")


def prong_grab_relief():
    margin = 0.3
    z_span = 1.0
    y_span = 5.6
    z0 = PRONG_GRAB_Z - z_span / 2
    y0 = -y_span / 2
    left = box_at(
        PRONG_GRAB_FACE_L - PRONG_GRAB_SHAVE,
        y0,
        z0,
        PRONG_GRAB_SHAVE + margin,
        y_span,
        z_span,
    )
    right = box_at(
        PRONG_GRAB_FACE_R - margin,
        y0,
        z0,
        PRONG_GRAB_SHAVE + margin,
        y_span,
        z_span,
    )
    return left.fuse(right)


def isolator_ledges(layout: ShellLayout):
    overlap = 0.3
    length = layout.shell_l - 2 * WALL + 2 * overlap
    x0 = layout.shell_ox + WALL - overlap
    south = box_at(
        x0,
        layout.shell_oy + WALL - overlap,
        layout.ledge_z,
        length,
        LEDGE_W + overlap,
        LEDGE_H,
    )
    north = box_at(
        x0,
        layout.shell_oy + layout.shell_w - WALL - LEDGE_W,
        layout.ledge_z,
        length,
        LEDGE_W + overlap,
        LEDGE_H,
    )
    return south.fuse(north)


def base_adapter(layout: ShellLayout, extra_cuts: list, finish_shell=None):
    """Hook plus pocket, with the caller's extra cutters removed.

    Small features are applied to the hook mesh first. The pocket is a
    separate solid until the final join, which keeps each mesh boolean small.
    """
    hook = load_hook()
    for name, shape in (
        ("sleeves", pin_sleeves(layout)),
        ("gussets", prong_root_reinforcement()),
    ):
        print(f"  fuse {name}", file=sys.stderr, flush=True)
        hook = hook.fuse(shape)
    print("  grab", file=sys.stderr, flush=True)
    hook = add_grab(hook)
    for name, cutter in (
        ("pins", pin_through_holes(layout)),
        ("relief", prong_grab_relief()),
    ):
        print(f"  cut {name}", file=sys.stderr, flush=True)
        hook = hook.cut(cutter)

    print("  shell", file=sys.stderr, flush=True)
    shell = pcb_shell(layout)
    shell = shell.cut(pcb_cavity(layout))
    shell = shell.cut(pin_through_holes(layout))
    for cutter in extra_cuts:
        shell = shell.cut(cutter)
    shell = shell.fuse(isolator_ledges(layout))
    if finish_shell is not None:
        shell = finish_shell(shell)

    print("  join", file=sys.stderr, flush=True)
    return hook.fuse(shell)


def print_orient(part, span_y: float, height: float):
    return Pos(0, span_y, height) * Rot(180, 0, 0) * part


def pry_notch(shell_l: float, shell_w: float, top_z: float, width: float, depth: float):
    return Pos(shell_l / 2, shell_w + 0.2, top_z) * Rot(0, 90, 0) * Cylinder(depth, width)
