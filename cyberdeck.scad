include <BOSL2/std.scad>
include <parameters.scad>

use <keyboard_components.scad>
use <battery_components.scad>
use <screen_components.scad>

show_cutaway = true;

render_top = false;
render_bottom = true;
render_battery_cover = true;

cutaway_depth_x = 300; // [0:300]
cutaway_depth_y = 180; // [0:300]
cutaway_depth_z = 300; // [0:40]

chamfer_size = [10, 10, 300];

chamfer_transforms = [
  [[0, 0, 0], 45],
  [[0, exterior_height, 0], 45],
  [[exterior_width, exterior_height, 0], 45],
  [[exterior_width, 0, 0], 45],
];

module interior_cutout_translate() {
  skew(szy=wedge_slope)
    translate([wall_depth, wall_depth, top_and_bottom_wall_depth])
      children();
}

module case_chamfer(position = [0, 0, 0], angle = [45, 0, 0], size = [10, 10, 10]) {
  difference() {
    children();
    for (i = chamfer_transforms) {
      pos = i[0];
      rot = i[1];
      translate(pos)
        rotate(rot)
          cube(chamfer_size * 2, center=true);
    }
  }
}

module cutaway() {
  difference() {
    children();

    if (show_cutaway)
      translate([-1, -1, -eps])
        cube([cutaway_depth_x + eps, cutaway_depth_y + eps, cutaway_depth_z + eps]);
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
    cube([interior_width, interior_height, interior_depth]);
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
    hull() {
      cube([exterior_width, 0.1, exterior_front_depth]);
      translate([0, exterior_height, 0])
        cube([exterior_width, 0.1, exterior_back_depth]);
    }
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
      for (i = chamfer_transforms) {
        pos = i[0];
        rot = i[1];
        translate(pos)
          rotate(rot)
            square(chamfer_size * 2, center=true);
      }
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

module case_bottom() {
  half_of(v=-wedge_normal, cp=[0, 0, case_split_z], s=1000)
    case();

  case_bottom_lip();
}

case_chamfer()
  cutaway() {
    if (render_top)
      half_of(v=wedge_normal, cp=[0, 0, case_split_z], s=1000)
        case();

    if (render_bottom) case_bottom();
  }
