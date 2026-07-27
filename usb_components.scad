include <parameters.scad>
include <hardware.scad>

/* [Cutaway] */

// Slice the model open to see the interior
show_cutaway = true;
// Axis the cut plane is perpendicular to
cutaway_axis = "y"; // [x, y, z]
// Where the cut plane sits along that axis
cutaway_at = 33; // [-5:0.5:70]
// Keep the side with the larger coordinate rather than the smaller
cutaway_keep_above = true;

/* [Dimensions] */

// The amount of space between the bottom of the PCB and the bottom of the interior of the case
usb_case_bottom_interior_depth = 2;
usb_case_top_interior_depth = 6;

usb_pcb_depth = 1.6;
usb_pcb_width = 25.5;
usb_pcb_height = 61.5;

// These are relative to the inside of the case
usb_pcb_bottom_mount_positions = [
  [11.4, 4 + tolerance],
  [21.1, usb_pcb_height - 3.25],
];
usb_pcb_bottom_mount_size = 4;

usb_cutout_pos = 16.5;
usb_x_cutout_depth = 9;
usb_y_cutout_depth = 15;

// This is the amount of overlap between the USB port and the PCB cutout
usb_port_overlap = 4;
// This is the depth of the USB port from the front lip of the port to the back of the port
usb_port_interior_length = 12.85;
usb_port_length = 13.9;
usb_port_width = 13.2;
usb_port_depth = 6;
usb_port_gap = 5.85;
usb_port_lip = 1;

usb_case_wall_depth = 2;
usb_case_width = usb_pcb_width + (usb_case_wall_depth * 2);
usb_case_height = usb_pcb_height + (usb_case_wall_depth * 2);
usb_case_depth = usb_pcb_depth + usb_case_bottom_interior_depth + usb_case_top_interior_depth + (usb_case_wall_depth * 2);

// How far the case runs past its normal wall to shroud the ports. The case
// face stops where the port's flare begins, so every port sits proud by
// usb_port_lip. Same on both port faces, so they can't drift apart.
usb_port_shroud_depth = usb_port_length - usb_case_wall_depth - usb_port_lip;

// The case's outer y run, shroud included. The lip window and the deck hole both
// key off this, so they can't disagree about how big the case is.
usb_case_outer_height = usb_case_height + usb_port_shroud_depth;

// Stop lip. Bears on the *outer* face of the cyberdeck wall, so the hub drops
// in from outside and can go no deeper. Two screws through the y ears hold it
// both ways; a bracket inside the deck takes the z load.
usb_case_lip_depth = 4;
// Asymmetric on purpose: the y ears carry the screws, z stays thin to keep the
// hub's vertical profile down.
usb_case_lip_overhang_y = 8;
usb_case_lip_overhang_z = 2;
// M3x8, same hardware as case_screw_* in parameters.scad. screw_hole adds
// tolerance to both radii itself, so these stay nominal.
usb_case_lip_screw_head_diameter = 5.35;
usb_case_lip_screw_thread_diameter = 3;
// Counterbore depth. Stops short of usb_case_lip_depth so there is material left
// behind the head to pull against.
usb_case_lip_screw_head_depth = 2;
// Screw center, measured outboard from the case's y faces
usb_case_lip_screw_inset = 4;

// ============================================================
// Cutaway
// ============================================================
// Cutaway
// ============================================================
// A cut is described as a plane, not as a box: pick an axis, pick where along
// it to slice, pick which side to keep. `reach` is the size of the discarded
// solid and only has to overshoot the model, so nothing needs hand-tuning.
module cutaway(axis = cutaway_axis, at = cutaway_at, keep_above = cutaway_keep_above, enabled = show_cutaway, reach = 500) {
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

// Where the board sits inside the case. Shared by the drawn PCB, the port
// cutouts, the interior pocket and the mount posts so they can't drift apart
// when a dimension changes. The case's left face is x = 0 and its front face is
// y = 0, so the -x shroud pushes the board inboard by usb_port_shroud_depth.
pcb_pos = [
  usb_port_shroud_depth + usb_case_wall_depth,
  usb_case_wall_depth,
  usb_case_wall_depth + usb_case_bottom_interior_depth,
];

// Every USB port, in PCB coordinates. `t` is grown clearance: 0 draws the real
// connectors, tolerance draws the pocket they sit in. One definition, so a port
// can't be added without its cutout following along.
module usb_ports(t = 0) {
  // Three side ports, facing -x. Clearance is applied on the -x face too, so
  // the pocket keeps clearing the front slab even if usb_port_lip changes.
  for (i = [0:2])
    translate([-usb_port_length - t, 5 + i * (usb_port_width + usb_port_gap) - t, -t])
      cube([usb_port_length + usb_port_overlap + (t * 2), usb_port_width + (t * 2), usb_port_depth + (t * 2)]);

  // One port on the far edge, facing +y.
  translate([usb_port_overlap - t, usb_pcb_height - usb_port_overlap - t, -t])
    cube([usb_port_width + (t * 2), usb_port_length + usb_port_overlap + (t * 2), usb_port_depth + (t * 2)]);
}

module pcb() {
  color("chocolate")
    linear_extrude(height=usb_pcb_depth)
      difference() {
        square([usb_pcb_width, usb_pcb_height]);

        translate([usb_cutout_pos, -eps, -eps]) square([usb_x_cutout_depth + eps, usb_y_cutout_depth]);
      }

  color("silver") usb_ports();
}

// The stop lip: a collar standing proud of the case's -x face. Its window is the
// case footprint, so the deck hole only has to clear the body — the collar itself
// lands on the deck's outer face and the ports sit recessed inside the pocket.
module usb_case_lip() {
  difference() {
    translate([-usb_case_lip_depth, -usb_case_lip_overhang_y, -usb_case_lip_overhang_z])
      cube(
        [
          usb_case_lip_depth,
          usb_case_outer_height + (usb_case_lip_overhang_y * 2),
          usb_case_depth + (usb_case_lip_overhang_z * 2),
        ]
      );

    // The window. Its floor is the case's own -x wall, so the ports end up
    // recessed by usb_case_lip_depth - usb_port_lip.
    translate([-usb_case_lip_depth - eps, 0, 0])
      cube([usb_case_lip_depth + (eps * 2), usb_case_outer_height, usb_case_depth]);

    // One screw per y ear, centered on the case depth. screw_hole descends in
    // -z from the face the head sits flush with, so the origin goes on the lip's
    // outer face and -90 about y aims the hole inboard, along +x. The thread runs
    // out whatever the counterbore leaves, making it a through-hole.
    for (y = [-usb_case_lip_screw_inset, usb_case_outer_height + usb_case_lip_screw_inset])
      translate([-usb_case_lip_depth, y, usb_case_depth / 2])
        rotate([0, -90, 0])
          screw_hole(
            head_depth=usb_case_lip_screw_head_depth,
            head_diameter=usb_case_lip_screw_head_diameter,
            thread_length=usb_case_lip_depth - usb_case_lip_screw_head_depth,
            thread_diameter=usb_case_lip_screw_thread_diameter
          );
  }
}

module usb_case() {
  difference() {
    color("steelblue") {
      difference() {
        cube(
          [
            usb_port_shroud_depth + usb_case_width,
            usb_case_outer_height,
            usb_case_depth,
          ]
        );

        // The board footprint plus slop, taken straight off the board position
        // so the pocket follows the board.
        translate([pcb_pos[0] - tolerance, pcb_pos[1] - tolerance, usb_case_wall_depth])
          cube([usb_pcb_width + (tolerance * 2), usb_pcb_height + (tolerance * 2), usb_case_depth - (usb_case_wall_depth * 2)]);
      }

      // Bottom mount posts
      for (pos = usb_pcb_bottom_mount_positions)
        translate(
          [
            pcb_pos[0] + pos[0] - usb_pcb_bottom_mount_size / 2,
            pcb_pos[1] + pos[1] - usb_pcb_bottom_mount_size / 2,
            usb_case_wall_depth,
          ]
        )
          cylinder(h=usb_case_bottom_interior_depth - tolerance, r=usb_pcb_bottom_mount_size / 2);

      usb_case_lip();
    }

    translate(pcb_pos) usb_ports(tolerance);
  }
}

cutaway() {
  usb_case();
  translate(pcb_pos) pcb();
}

echo("Case depth: ", usb_case_depth);
echo("Deck hole (y x z): ", usb_case_outer_height, usb_case_depth);
echo(
  "Lip outer (y x z): ",
  usb_case_outer_height + (usb_case_lip_overhang_y * 2),
  usb_case_depth + (usb_case_lip_overhang_z * 2)
);
