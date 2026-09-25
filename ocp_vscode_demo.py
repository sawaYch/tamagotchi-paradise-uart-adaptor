"""Preview the wireless adaptor in OCP CAD Viewer.

Run this file with Run > Run Without Debugging (Ctrl+F5).
The adapter is the exported STL, so the viewer does not rebuild the hook mesh.
"""

from build123d import Pos, import_stl
from ocp_vscode import Camera, show

from adaptor.shared import HOOK_H, ROOT
from adaptor.wireless import layout, lid_body

shell = layout()
adapter = import_stl(ROOT / "models" / "wireless" / "wireless-adaptor.stl")
lid = Pos(shell.shell_ox, shell.shell_oy, HOOK_H + shell.shell_h) * lid_body(shell)

show(
    adapter,
    lid,
    names=["adapter", "lid"],
    colors=["#d9d9d9", "#4c8ed9"],
    alphas=[1, 0.72],
    axes=True,
    grid=(True, True, True),
    reset_camera=Camera.RESET,
)
