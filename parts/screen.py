# %% imports and shared params — rarely re-run
# %load_ext autoreload
# %autoreload 2

import cadquery as cq
from ocp_vscode import set_defaults, show
from config import EXTERIOR_HEIGHT, EXTERIOR_LENGTH, EXTERIOR_WIDTH, SCREEN_CASE_LENGTH, SCREEN_CASE_WIDTH, SCREEN_LENGTH, SCREEN_WIDTH, SCREEN_HEIGHT, M3_THREADED_INSERT_HEIGHT

set_defaults(orbit_control=True)

# %%

SCREEN_STANDOFF_POSITIONS = [
  [10, 10, 0],
  [SCREEN_WIDTH - 10, 10, 0],
  [10, SCREEN_LENGTH - 10, 0],
  [SCREEN_WIDTH - 10, SCREEN_LENGTH - 10, 0],
];

def build():
    screen_case = (
        cq.Workplane()
            .box(SCREEN_CASE_LENGTH / 2, SCREEN_CASE_WIDTH / 2, EXTERIOR_HEIGHT)
            .edges("|Z")
            .fillet(4)
    )
    return screen_case

def screen() -> cq.Workplane:
    screen_standoffs = (
        cq.Workplane()
            .workplane(offset=-(EXTERIOR_HEIGHT / 2))
            .transformed(offset=(0, 0, 0))
            .pushPoints(SCREEN_STANDOFF_POSITIONS)
            .circle(M3_THREADED_INSERT_HEIGHT / 2)
            .extrude(M3_THREADED_INSERT_HEIGHT)
    )
   
    screen = (
        cq.Workplane()
            .box(SCREEN_LENGTH, SCREEN_WIDTH, SCREEN_HEIGHT)
            .edges("|Z")
            .fillet(4)
            .add(screen_standoffs)
    )
    return screen

if __name__ == "__main__":
#   show(build())

  show(screen())

# %%
