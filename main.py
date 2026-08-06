import math
import cadquery as cq
from cadquery.func import *
from parts.keyboard import build as buildKeyboard
from config import TOP_WALL_THICKNESS, WALL_THICKNESS, EXTERIOR_WIDTH, EXTERIOR_LENGTH, EXTERIOR_HEIGHT, INTERIOR_HEIGHT, KEYBOARD_WIDTH, KEYBOARD_LENGTH, SCREEN_WIDTH, SCREEN_LENGTH
from ocp_vscode import show, set_defaults

set_defaults(orbit_control=True)

CUTOUT_DEPTH = TOP_WALL_THICKNESS
WEDGE_ANGLE = 10

keyboard_cutout = (
  cq.Sketch()
    .rect(KEYBOARD_LENGTH, KEYBOARD_WIDTH)
)

screen_cutout = (
    cq.Sketch()
      .rect(SCREEN_LENGTH, SCREEN_WIDTH)
)

screen_cutout_location = (
  (-(EXTERIOR_LENGTH / 2 - SCREEN_LENGTH / 2) + 20, (EXTERIOR_WIDTH / 2 - SCREEN_WIDTH / 2) - 20)
)

keyboard_cutout_location = (
  (0, -(EXTERIOR_WIDTH / 2 - KEYBOARD_WIDTH / 2 - 10))
)

# Taper runs along +Y. `slope` is the rise per unit Y (== SCAD wedge_slope).
slope = math.tan(math.radians(WEDGE_ANGLE))

# CadQuery analog of SCAD's skew(szy): z += slope * y. Wrap any solid in this
# to make it tilt with the wedge — the cavity, and every boss/insert/screw/
# component mounted inside, so they all sit angled to the flat bottom.
def sheared(shape):
  return shape.transformGeometry(cq.Matrix([
    [1, 0, 0,     0],
    [0, 1, 0,     0],
    [0, slope, 1, 0],
  ]))

# Top plane at y=0. Front edge (y=-W/2) lands at EXTERIOR_HEIGHT.
top_z = EXTERIOR_HEIGHT + slope * EXTERIOR_WIDTH / 2

# Exterior: flat bottom, sloped top. Trapezoid in Y-Z extruded along X.
exterior = (
  cq.Workplane("YZ")
    .polyline([
      (-EXTERIOR_WIDTH / 2, 0),
      ( EXTERIOR_WIDTH / 2, 0),
      ( EXTERIOR_WIDTH / 2, top_z + slope * EXTERIOR_WIDTH / 2),  # tall back
      (-EXTERIOR_WIDTH / 2, top_z - slope * EXTERIOR_WIDTH / 2),  # short front
    ]).close()
    .extrude(EXTERIOR_LENGTH / 2, both=True)                     # centered on X
)

# Interior: straight box, then sheared. Floor AND top both slope at the wedge
# angle and stay parallel; top wall = TOP_WALL_THICKNESS everywhere.
interior_top = top_z - TOP_WALL_THICKNESS
interior = sheared(
  cq.Solid.makeBox(
    EXTERIOR_LENGTH - 2 * WALL_THICKNESS,
    EXTERIOR_WIDTH - 2 * WALL_THICKNESS,
    INTERIOR_HEIGHT,
    cq.Vector(
      -(EXTERIOR_LENGTH / 2 - WALL_THICKNESS),
      -(EXTERIOR_WIDTH / 2 - WALL_THICKNESS),
      interior_top - INTERIOR_HEIGHT,
    ),
  )
)

case = (
  exterior
    .edges("|Z")
      .fillet(4)
    .faces(">Z")
      .workplane()
        .moveTo(*screen_cutout_location)
          .placeSketch(screen_cutout)
          .cutBlind(-CUTOUT_DEPTH)
        .moveTo(*keyboard_cutout_location)
            .placeSketch(keyboard_cutout)
            .cutBlind(-CUTOUT_DEPTH)
    .cut(interior)
)

assembly = (
  cq.Assembly()
    .add(case)
    # .add(top_wedge)
    # .add(beans)
    # .add(buildKeyboard())
)

show(assembly)

