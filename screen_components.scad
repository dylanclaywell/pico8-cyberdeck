include <parameters.scad>

screen_mount_depth = interior_depth - screen_depth_to_mount;

screw_hole_positions = [
  [10, 10, 0],
  [screen_width - 10, 10, 0],
  [10, screen_height - 10, 0],
  [screen_width - 10, screen_height - 10, 0],
];

module screen_cutout() {
  cube([screen_width, screen_height, 100]);
}

// Screw driven from the OUTSIDE bottom of the case, up through the bottom wall
// to meet the base of the standoff. A single washer-wide pocket clears the
// whole (wedge-tilted, non-uniform) wall; the screw threads engage the standoff
// above, whose hole is cut by screw_holes() in screen_mount().
//
// This MUST be placed inside interior_cutout_translate (same as screen_mount)
// so it inherits the 2 deg wedge skew and stays collinear with the standoff's
// screw axis. In that frame the standoff base is local z = 0.
screen_bottom_hole_overshoot = 20; // generous; clipped by the outer skin

module screen_mount_bottom_holes() {
  for (i = screw_hole_positions) {
    // Overshoot below the outer face (trimmed by the body), top at z = 0 so
    // the pocket meets the standoff base without hollowing its threads.
    translate([i[0], i[1], -screen_bottom_hole_overshoot + eps])
      cylinder(
        h=screen_bottom_hole_overshoot,
        r=(screen_screw_washer_diameter + tolerance) / 2
      );
  }
}

module screw_holes() {
  for (i = screw_hole_positions) {
    x = i[0];
    y = i[1];
    translate([i[0], i[1], i[2] - eps])
      color("yellow")
        cylinder(h=screen_mount_depth + (eps * 2), r=screen_screw_thread_diameter / 2);
  }
}

module screen_mount() {
  difference() {
    cube([screen_width, screen_height, screen_mount_depth]);
    screw_holes();
  }
}

%screen_cutout();
translate([100, 0, 0]) screen_mount();
translate([200, 0, 0]) screen_mount_bottom_holes();
