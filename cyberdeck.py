# %% imports and shared params — rarely re-run
import cadquery as cq
from ocp_vscode import show, set_defaults
plate_width, plate_height, hole_dia = 80, 40, 5

set_defaults(orbit_control=True)

# %%
# shared parameters for the cyberdeck design

exterior_length = 255
exterior_width = 210

# %%

deck = cq.Workplane().box(exterior_length, exterior_width, 30)

keyboard_case = cq.Workplane().box(exterior_length, exterior_width / 2, 30)

show(keyboard_case)

# %%
