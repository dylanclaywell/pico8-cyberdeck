# %% imports and shared params — rarely re-run
%load_ext autoreload
%autoreload 2

import cadquery as cq
from cadquery.func import *
from parts.keyboard import build as buildKeyboard
from ocp_vscode import show, set_defaults
plate_width, plate_height, hole_dia = 80, 40, 5

set_defaults(orbit_control=True)

assembly = (
  cq.Assembly()
    .add(buildKeyboard())
)

show(assembly)

# %%
