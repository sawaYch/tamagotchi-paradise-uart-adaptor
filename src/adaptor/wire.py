"""FT232RL wired UART adaptor and friction-fit lid."""

from build123d import Pos, RectangleRounded, Rot, extrude

from adaptor.shared import (
    HEADROOM,
    HOOK_R,
    TOLERANCE,
    WALL,
    WALL_INNER,
    ShellLayout,
    base_adapter,
    print_orient,
    pry_notch,
    rounded_box,
)

PCB_L = 36.0
PCB_W = 18.0
PCB_THICKNESS = 1.6
JUMPER_H = 9.0
PCB_H = PCB_THICKNESS + JUMPER_H
USB_W = 9.0
USB_H = 3.2
USB_OVERHANG = 1.2
HEADER_OVERHANG = 2.0

USB_CUT_TOL = 0.6
USB_CUT_ROUND_R = 2.5

LID_T = 1.6
LID_INNER_CLEAR = 0.03
LID_INNER_H = 3.0
LID_INNER_T = 1.2
LID_PRY_W = 10.0
LID_PRY_D = 1.2

USB_CUT_W = USB_W + 2 * TOLERANCE + 0.6
USB_CUT_H = USB_H + 2 * TOLERANCE


def layout() -> ShellLayout:
    return ShellLayout(
        pcb_cav_l=PCB_L + 2 * TOLERANCE + USB_OVERHANG + HEADER_OVERHANG,
        pcb_cav_w=PCB_W + 2 * TOLERANCE,
        pcb_cav_h=PCB_H + TOLERANCE + HEADROOM,
    )


def usb_cutout(shell: ShellLayout):
    cut_w = USB_CUT_W + 2 * USB_CUT_TOL
    cut_h = USB_CUT_H + 2 * USB_CUT_TOL
    depth = WALL + 6
    radius = min(USB_CUT_ROUND_R, cut_w / 2 - 0.2, cut_h / 2 - 0.2)
    sketch = RectangleRounded(cut_h, cut_w, radius)
    extruded = extrude(sketch, amount=depth)
    x0 = shell.shell_ox - 0.2
    y0 = shell.shell_oy + (shell.shell_w - cut_w) / 2
    z0 = shell.pcb_z + PCB_THICKNESS + USB_H / 2
    return Pos(x0, y0 + cut_w / 2, z0) * Rot(0, 90, 0) * extruded


def adapter():
    shell = layout()
    return base_adapter(shell, [usb_cutout(shell)])


def lid_body(shell: ShellLayout):
    plug_l = shell.shell_l - 2 * WALL_INNER - 2 * LID_INNER_CLEAR
    plug_w = shell.shell_w - 2 * WALL_INNER - 2 * LID_INNER_CLEAR
    plate = rounded_box(shell.shell_l, shell.shell_w, LID_T, HOOK_R)
    plug_outer = rounded_box(plug_l, plug_w, LID_INNER_H + 0.4, 0.5)
    plug_void = Pos(LID_INNER_T, LID_INNER_T, -1) * rounded_box(
        plug_l - 2 * LID_INNER_T,
        plug_w - 2 * LID_INNER_T,
        LID_INNER_H + 3,
        0.3,
    )
    plug = Pos(WALL + LID_INNER_CLEAR, WALL + LID_INNER_CLEAR, -LID_INNER_H) * plug_outer.cut(
        plug_void
    )
    body = plate.fuse(plug)
    return body.cut(pry_notch(shell.shell_l, shell.shell_w, LID_T, LID_PRY_W, LID_PRY_D))


def lid():
    shell = layout()
    return print_orient(lid_body(shell), shell.shell_w, LID_T)
