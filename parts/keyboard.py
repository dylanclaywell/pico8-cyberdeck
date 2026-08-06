# %% imports and shared params — rarely re-run
# %load_ext autoreload
# %autoreload 2

import cadquery as cq
from ocp_vscode import set_defaults, show
from config import EXTERIOR_HEIGHT, EXTERIOR_LENGTH, EXTERIOR_WIDTH, KEYBOARD_LENGTH, KEYBOARD_WIDTH, KEYBOARD_CASE_BOTTOM_WALL_THICKNESS, M3_THREADED_INSERT_DIAMETER, TOLERANCE, KEYBOARD_CASE_POSTS_HEIGHT, KEYBOARD_CASE_POSTS_DIAMETER, M3_THREADED_INSERT_HEIGHT

set_defaults(orbit_control=True)

# %%

KEYBOARD_MOUNT_POSITIONS = ([
  # top left
  (20.25, KEYBOARD_WIDTH - 9.25),

  # top middle
  (96.50, KEYBOARD_WIDTH - 9.25),

  # top right
  (KEYBOARD_LENGTH - 20.25, KEYBOARD_WIDTH - 9.25),

  # bottom left
  (20.25, 11.25),

  # bottom middle
  (KEYBOARD_LENGTH - 96.50, 11.25),

  # bottom right
  (KEYBOARD_LENGTH - 20.25, 11.25),
])

def build() -> cq.Workplane:
  interior_cutout = (
    cq.Sketch()
      .rect(KEYBOARD_LENGTH + TOLERANCE, KEYBOARD_WIDTH + TOLERANCE)
  )

  interior_floor_z = -(EXTERIOR_HEIGHT / 2 - KEYBOARD_CASE_BOTTOM_WALL_THICKNESS)
  post_taper = 3

  posts = (
    cq.Workplane()
      .workplane(offset=interior_floor_z)
      .transformed(offset=(-KEYBOARD_LENGTH / 2, -KEYBOARD_WIDTH / 2,  0))
      .pushPoints(KEYBOARD_MOUNT_POSITIONS)
      .circle((KEYBOARD_CASE_POSTS_DIAMETER + post_taper) / 2)
      .extrude(KEYBOARD_CASE_POSTS_HEIGHT, taper=post_taper)
      .faces(">Z")
      .circle(M3_THREADED_INSERT_DIAMETER / 2)
      .cutBlind(-M3_THREADED_INSERT_HEIGHT)
  )

  keyboard_case = (
    cq.Workplane()
      .box(EXTERIOR_LENGTH, EXTERIOR_WIDTH / 2, EXTERIOR_HEIGHT)
      .edges("|Z")
      .fillet(4)
      .faces(">Z")
      .placeSketch(interior_cutout)
      .cutBlind(-(EXTERIOR_HEIGHT - KEYBOARD_CASE_BOTTOM_WALL_THICKNESS))
  )

  keyboard_case = keyboard_case.union(posts)

  # pcb = (
  #   cq.Workplane()
  #     .box(KEYBOARD_LENGTH, KEYBOARD_WIDTH, 1)
  # )
  return keyboard_case

if __name__ == "__main__":
  show(build())
# %%
