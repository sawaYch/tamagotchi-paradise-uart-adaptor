"""JDY-23 wireless UART adaptor and magnetic lid."""

from __future__ import annotations

import math

from build123d import Circle, Polygon, Pos, Rot, SlotCenterToCenter, extrude

from adaptor.shared import (
    EPS,
    HEADROOM,
    HOOK_H,
    HOOK_R,
    TOLERANCE,
    WALL,
    ShellLayout,
    base_adapter,
    convex_hull,
    cylinder_up,
    fuse_all,
    print_orient,
    pry_notch,
    rounded_box,
)

PCB_L = 32.7
PCB_W = 18.3
PCB_THICKNESS = 1.6
MODULE_H = 1.8
HEADER_H = 8.5
PCB_H = PCB_THICKNESS + HEADER_H
PIN_SOLDER_CLEAR = 6.0
SIDE_WIRE_CLEAR = 1.5

BLE_SYMBOL_H = 9.0
BLE_SYMBOL_STROKE = 1.35

MAG_D = 5.0
MAG_H = 2.0
MAG_FIT = 0.3
MAG_POCKET_D = MAG_D + MAG_FIT
MAG_POCKET_H = MAG_H + 0.15
MAG_FLOOR = 0.7
MAG_SKIN = 0.8
MAG_WALL_SKIN = 1.2
MAG_INSET = max(
    MAG_POCKET_D / 2 + MAG_WALL_SKIN,
    HOOK_R + (HOOK_R + MAG_POCKET_D / 2 + MAG_SKIN + 0.3) / math.sqrt(2),
)
MAG_BOSS_D = 2 * (MAG_INSET - 0.6)
MAG_BOSS_H = MAG_POCKET_H + MAG_FLOOR

FP_BODY_L = 12.5
FP_EAR_L = 14.5
FP_W = 4.0
FP_H = 4.0
FP_EAR_T = 1.0
FP_FIT = 0.2

LID_T = FP_H
LID_PRY_W = 10.0
LID_PRY_D = 1.2


def layout() -> ShellLayout:
    return ShellLayout(
        pcb_cav_l=PCB_L + 2 * TOLERANCE + PIN_SOLDER_CLEAR,
        pcb_cav_w=PCB_W + 2 * TOLERANCE + 2 * SIDE_WIRE_CLEAR,
        pcb_cav_h=PCB_H + TOLERANCE + HEADROOM,
    )


def _bar(a: tuple[float, float], b: tuple[float, float], thickness: float):
    dx = b[0] - a[0]
    dy = b[1] - a[1]
    length = math.hypot(dx, dy)
    angle = math.degrees(math.atan2(dy, dx))
    mid = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
    return Pos(mid[0], mid[1]) * Rot(0, 0, angle) * SlotCenterToCenter(length, thickness)


def _perp_support(ax, ay, bx, by, length: float, width: float):
    mx = (ax + bx) / 2
    my = (ay + by) / 2
    dx = bx - ax
    dy = by - ay
    nlen = math.hypot(dx, dy)
    nx = -dy / nlen
    ny = dx / nlen
    return _bar(
        (mx - nx * length / 2, my - ny * length / 2),
        (mx + nx * length / 2, my + ny * length / 2),
        width,
    )


def bluetooth_symbol(height: float, stroke: float):
    tip_x = height * 0.40
    mid_y = height * 0.06
    support_w = max(0.9, stroke * 0.75)
    support_len = stroke + height * 0.28
    bars = [
        _bar((0, height / 2), (0, -height / 2), stroke),
        _bar((0, height / 2), (tip_x, mid_y), stroke),
        _bar((tip_x, mid_y), (0, -mid_y), stroke),
        _bar((0, mid_y), (tip_x, -mid_y), stroke),
        _bar((tip_x, -mid_y), (0, -height / 2), stroke),
        _bar((-tip_x, height * 0.34), (0, 0), stroke),
        _bar((-tip_x, -height * 0.34), (0, 0), stroke),
    ]
    symbol = fuse_all(bars)
    bridges = [
        _perp_support(0, height / 2, tip_x, mid_y, support_len, support_w),
        _perp_support(tip_x, -mid_y, 0, -height / 2, support_len, support_w),
    ]
    return symbol.cut(*bridges)


def ble_cutout(shell: ShellLayout):
    depth = WALL + 6
    x0 = shell.shell_ox + shell.shell_l + 0.2
    z0 = shell.pcb_z + PCB_THICKNESS + MODULE_H / 2
    symbol = Rot(0, 0, 90) * bluetooth_symbol(BLE_SYMBOL_H, BLE_SYMBOL_STROKE)
    extruded = extrude(symbol, amount=depth)
    return Pos(x0, 0, z0) * Rot(0, -90, 0) * extruded


def magnet_positions(shell: ShellLayout) -> list[tuple[float, float]]:
    inset = MAG_INSET
    return [
        (inset, inset),
        (shell.shell_l - inset, inset),
        (inset, shell.shell_w - inset),
        (shell.shell_l - inset, shell.shell_w - inset),
    ]


def _circle_hull(c1, r1, c2, r2):
    points = []
    for cx, cy, radius in ((*c1, r1), (*c2, r2)):
        for i in range(48):
            angle = 2 * math.pi * i / 48
            points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    return Polygon(*convex_hull(points))


def magnet_corner_sketch(shell: ShellLayout, extra: float = 0.0):
    big_r = (MAG_BOSS_D + 2 * extra) / 2
    small_r = max(0.4, 2 * extra) / 2
    faces = []
    for px, py in magnet_positions(shell):
        cx = -extra if px < shell.shell_l / 2 else shell.shell_l + extra
        cy = -extra if py < shell.shell_w / 2 else shell.shell_w + extra
        faces.append(_circle_hull((px, py), big_r, (cx, cy), small_r))
    return fuse_all(faces)


def magnet_bosses(shell: ShellLayout):
    z0 = HOOK_H + shell.shell_h - MAG_BOSS_H
    slab = Pos(shell.shell_ox, shell.shell_oy, z0) * rounded_box(
        shell.shell_l, shell.shell_w, MAG_BOSS_H, HOOK_R
    )
    corners = Pos(shell.shell_ox, shell.shell_oy, z0 - EPS) * extrude(
        magnet_corner_sketch(shell), amount=MAG_BOSS_H + 2 * EPS
    )
    bosses = slab.intersect(corners)
    if not hasattr(bosses, "wrapped"):
        bosses = fuse_all(list(bosses))
    return bosses


def magnet_pockets(shell: ShellLayout, z0: float, height: float):
    return fuse_all(
        [
            cylinder_up(shell.shell_ox + px, shell.shell_oy + py, z0, height, MAG_POCKET_D)
            for px, py in magnet_positions(shell)
        ]
    )


def stadium(length: float, width: float):
    radius = width / 2
    separation = max(0.0, length - width)
    if separation < 1e-6:
        return Circle(radius)
    return SlotCenterToCenter(separation, width)


def female_pogo_pocket(shell: ShellLayout):
    cx = shell.shell_l / 2
    cy = shell.shell_w / 2
    body_l = FP_BODY_L + 2 * FP_FIT
    ear_l = FP_EAR_L + 2 * FP_FIT
    width = FP_W + 2 * FP_FIT
    ear_z2 = (FP_H + FP_EAR_T) / 2
    ears = Pos(cx, cy, -EPS) * extrude(stadium(ear_l, width), amount=ear_z2 + EPS)
    body = Pos(cx, cy, ear_z2 - EPS) * extrude(
        stadium(body_l, width), amount=FP_H - ear_z2 + 2 * EPS
    )
    return ears.fuse(body)


def adapter():
    shell = layout()

    def finish(pocket):
        pockets = magnet_pockets(shell, HOOK_H + shell.shell_h - MAG_POCKET_H, MAG_POCKET_H + 1)
        return pocket.fuse(magnet_bosses(shell)).cut(pockets)

    return base_adapter(shell, [ble_cutout(shell)], finish_shell=finish)


def lid_body(shell: ShellLayout):
    plate = rounded_box(shell.shell_l, shell.shell_w, FP_H, HOOK_R)
    pockets = fuse_all(
        [
            cylinder_up(px, py, -EPS, MAG_POCKET_H + EPS, MAG_POCKET_D)
            for px, py in magnet_positions(shell)
        ]
    )
    cutters = fuse_all(
        [
            pockets,
            female_pogo_pocket(shell),
            pry_notch(shell.shell_l, shell.shell_w, LID_T, LID_PRY_W, LID_PRY_D),
        ]
    )
    return plate.cut(cutters)


def lid():
    shell = layout()
    return print_orient(lid_body(shell), shell.shell_w, FP_H)
