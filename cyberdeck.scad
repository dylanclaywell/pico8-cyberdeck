include <BOSL2/std.scad>
include <parameters.scad>

use <keyboard_components.scad>
use <battery_components.scad>
use <screen_components.scad>
use <usb_components.scad>
use <hardware.scad>

/* [Cutaway] */

// Slice the model open to see the interior
show_cutaway = true;
// Axis the cut plane is perpendicular to
cutaway_axis = "y"; // [x, y, z]
// Where the cut plane sits along that axis
cutaway_at = 90; // [0:0.5:260]
// Keep the side with the larger coordinate rather than the smaller
cutaway_keep_above = true;

/* [Rendering] */

render_top = false;
render_bottom = true;
render_battery_cover = true;
render_usb_hub = true;

chamfer_size = [10, 10, 300];

// Corner chamfer cut transforms for a w x h rectangle: position + rotation
// for each of the 4 corners, meant to be subtracted with chamfer_size.
function corner_chamfer_transforms(w, h) = [
  [[0, 0, 0], 45],
  [[0, h, 0], 45],
  [[w, h, 0], 45],
  [[w, 0, 0], 45],
];

chamfer_transforms = corner_chamfer_transforms(exterior_width, exterior_height);
interior_chamfer_transforms = corner_chamfer_transforms(interior_width, interior_height);

// Subtracts corner chamfers from children at each of `transforms`' positions.
// Children should be the chamfer cut shape (e.g. square/cube(chamfer_size * 2, center=true)).
module corner_chamfers(transforms) {
  for (i = transforms) {
    pos = i[0];
    rot = i[1];
    translate(pos)
      rotate(rot)
        children();
  }
}

screw_mount_positions = [
  [case_screw_mount_spacing, case_screw_mount_spacing, 0],
  [interior_width - case_screw_mount_spacing, case_screw_mount_spacing, 0],
  [case_screw_mount_spacing, interior_height - case_screw_mount_spacing, 0],
  [interior_width - case_screw_mount_spacing, interior_height - case_screw_mount_spacing, 0],
  [interior_width / 2, 6, 0],
  [interior_width / 2, interior_height - 6, 0],
];

module interior_cutout_translate() {
  skew(szy=wedge_slope)
    translate([wall_depth, wall_depth, top_and_bottom_wall_depth])
      children();
}

// 2D exterior footprint: full rectangle with the 4 vertical corner
// chamfers subtracted. Single source of truth for the case outline;
// extruded for the exterior, mirrors case_bottom_lip_profile's shape.
module case_footprint() {
  difference() {
    square([exterior_width, exterior_height]);
    corner_chamfers(chamfer_transforms) square(chamfer_size * 2, center=true);
  }
}

// Exterior solid: extrude the chamfered footprint into a tall prism,
// then shear off the top to produce the front-to-back wedge taper.
module case_exterior() {
  difference() {
    linear_extrude(exterior_back_depth + 1)
      case_footprint();

    translate([0, 0, exterior_front_depth])
      skew(szy=wedge_slope)
        translate([-1, -1, 0])
          cube([exterior_width + 2, exterior_height + 2, exterior_back_depth + 2]);
  }
}

module case_top_screw_cutouts() {
  interior_cutout_translate() {
    for (i = screw_mount_positions) {
      x = i[0];
      y = i[1];

      translate([x, y, interior_depth - eps])
        cylinder(h=top_and_bottom_wall_depth + eps * 2, r=case_screw_head_diameter / 2 + tolerance);
    }
  }
}

module case_top_screw_mounts() {
  for (i = screw_mount_positions) {
    x = i[0];
    y = i[1];

    mount_z = case_split_z - top_and_bottom_wall_depth + case_bottom_lip_depth + tolerance;

    translate([x, y, mount_z])
      difference() {
        color("yellow")
          cylinder(h=interior_depth - case_split_z + case_bottom_lip_depth, r=case_screw_mount_diameter / 2);
        translate([0, 0, case_screw_head_depth + case_screw_spacing])
          screw_hole(
            case_screw_head_depth,
            case_screw_head_diameter,
            case_screw_thread_length,
            case_screw_thread_diameter
          );
      }
  }
}

module case_bottom_screw_mounts() {
  for (i = screw_mount_positions) {
    x = i[0];
    y = i[1];

    mount_depth = case_split_z - top_and_bottom_wall_depth;

    translate([x, y])
      difference() {
        color("yellow")
          cylinder(h=mount_depth, r=case_screw_mount_diameter / 2);
        translate([0, 0, mount_depth - threaded_insert_depth])
          cylinder(h=30, r=threaded_insert_diameter / 2 + tolerance);
      }
  }
}

// A cut is described as a plane, not as a box: pick an axis, pick where along
// it to slice, pick which side to keep. `reach` is the size of the discarded
// solid and only has to overshoot the model, so nothing needs hand-tuning.
module cutaway(axis = cutaway_axis, at = cutaway_at, keep_above = cutaway_keep_above, enabled = show_cutaway, reach = 600) {
  // Fail loudly on a bad axis. Without this a typo is silent: "Y" falls
  // through the lookup below and cuts z, giving wrong geometry, not an error.
  assert(axis == "x" || axis == "y" || axis == "z", str("cutaway: bad axis '", axis, "'"));

  i = axis == "x" ? 0 : axis == "y" ? 1 : 2;

  // On the cut axis the discarded solid starts at the plane and runs away from
  // the side being kept; on the other two it is centered so it spans the model.
  origin = [for (k = [0:2]) k == i ? (keep_above ? at - reach : at) : -reach / 2];

  difference() {
    children();

    if (enabled)
      translate(origin) cube(reach);
  }
}

module case_cutouts() {
  interior_cutout_translate() {
    translate([keyboard_x, keyboard_y, 0]) keyboard_cutout([keyboard_x, keyboard_y, 0], [keyboard_width, keyboard_height, 80]);
    translate([battery_x - 3, battery_y - 3, interior_depth]) battery_cutout();
    translate([screen_x, screen_y, 0]) screen_cutout();

    // Inside interior_cutout_translate so it inherits the wedge skew
    // and stays collinear with the standoff. Overshoots the bottom;
    // trimmed by the outer skin.
    translate([screen_x, screen_y, 0]) screen_mount_bottom_holes();

    // This is the interior volume of the case
    difference() {
      cube([interior_width, interior_height, interior_depth]);
      corner_chamfers(interior_chamfer_transforms) cube(chamfer_size * 2, center=true);
    }
  }
}

module case_interior_mounts() {
  interior_cutout_translate() {
    translate([keyboard_x, keyboard_y, 0]) keyboard_mount();

    translate([battery_x, battery_y, 0]) battery_mount();
    if (render_battery_cover) translate([battery_x - 3, battery_y - 3, interior_depth]) battery_cover();
    translate([battery_x - 3, battery_y - 3, interior_depth - threaded_insert_depth - threaded_insert_vertical_spacing]) battery_cover_mount();

    translate([screen_x, screen_y, 0]) screen_mount();
  }
}

module case() {
  difference() {
    case_exterior();
    case_cutouts();
  }

  case_interior_mounts();
}

module case_bottom_lip_profile(tol = 0) {
  translate([tol, tol, 0])
    difference() {
      square(
        [
          interior_width - (tol * 2),
          interior_height - (tol * 2),
        ]
      );
      corner_chamfers(interior_chamfer_transforms) square(chamfer_size * 2, center=true);
    }
}

module case_bottom_lip() {
  interior_cutout_translate() {
    translate([0, 0, 0]) {
      linear_extrude(case_split_z - top_and_bottom_wall_depth) {
        difference() {
          case_bottom_lip_profile();
          offset(delta=-case_bottom_lip_depth) case_bottom_lip_profile();
        }
      }

      translate([0, 0, case_split_z - top_and_bottom_wall_depth])
        linear_extrude(case_bottom_lip_depth) {
          difference() {
            case_bottom_lip_profile(tolerance);
            offset(delta=-case_bottom_lip_depth) case_bottom_lip_profile();
          }
        }
    }
  }
}

module case_top() {
  half_of(v=wedge_normal, cp=[0, 0, case_split_z], s=1000)
    case();

  interior_cutout_translate() {
    case_top_screw_mounts();
  }
}

module case_bottom() {
  half_of(v=-wedge_normal, cp=[0, 0, case_split_z], s=1000)
    case();

  case_bottom_lip();

  interior_cutout_translate() {
    case_bottom_screw_mounts();
  }
}

cutaway() {
  if (render_top) {
    difference() {
      case_top();

      case_top_screw_cutouts();
    }
  }

  if (render_bottom) {
    difference() {
      case_bottom();

      // Outside interior_cutout_translate() on purpose — the hub is square to the floor, not
      // to the wedge.
      translate(usb_hub_pos) usb_case_cutout(tolerance);
      translate(usb_hub_pos) usb_case_flange_holes();
    }
  }

  if (render_usb_hub) translate(usb_hub_pos) usb_case();
}
