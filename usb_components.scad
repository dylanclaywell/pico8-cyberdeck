include <BOSL2/std.scad>
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

/* [Rendering] */

render_top = true;
render_bottom = true;
render_pcb = true;

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

usb_case_bottom_lip_depth = 3;

// How far the case runs past its normal wall to shroud the ports. The case
// face stops where the port's flare begins, so every port sits proud by
// usb_port_lip. Same on both port faces, so they can't drift apart.
usb_port_shroud_depth = usb_port_length - usb_case_wall_depth - usb_port_lip;

// The -x wall is not a normal wall: it carries the shroud, so it runs thick and
// the ports bore through it. Every interior x position keys off this, so the
// board and its pocket can't drift from the face the ports poke out of.
usb_case_wall_x_neg = usb_port_shroud_depth + usb_case_wall_depth;

// The case's outer runs, shroud included. The shroud grows both axes (side ports
// face -x, the far port faces +y), so the case is asymmetric in x: a thick -x
// wall and a normal +x one. That's why there's no single pcb + 2 * wall
// expression for the x run. The lip window, the deck hole and the screw ears all
// key off these, so they can't disagree about how big the case is.
usb_case_outer_width = usb_case_wall_x_neg + usb_pcb_width + usb_case_wall_depth;
usb_case_outer_height = usb_case_height + usb_port_shroud_depth;

// Stop lip. Bears on the *outer* face of the cyberdeck wall, so the hub drops
// in from outside and can go no deeper. Two screws through the y ears hold it
// both ways; a bracket inside the deck takes the z load.
usb_case_lip_depth = 4;
usb_case_lip_overhang_y = 2;
usb_case_lip_overhang_z = 2;

// The collar straddles x = 0 instead of standing entirely forward of the body.
// Fully forward it would be a usb_case_lip_depth flange floating off nothing, so
// half of it is backed by case body and only usb_case_lip_proud projects past the
// -x face. Ports end up recessed inside the collar by
// usb_case_lip_proud - usb_port_lip.
usb_case_lip_proud = usb_case_lip_depth / 2;

// The deck's outer surface: the collar's back face, where it stops against the
// cyberdeck wall. The body from here to usb_case_outer_width is what the deck
// hole has to clear.
usb_deck_face_x = usb_case_lip_depth - usb_case_lip_proud;

m2_4_threaded_insert_length = 3.9;
m2_4_threaded_insert_diameter = 3.33;
m2_screw_head_diameter = 3.7;
m2_screw_thread_diameter = 2;

m3_6_threaded_insert_length = 6;
m3_6_threaded_insert_diameter = 4;
m3_screw_head_diameter = 5.5;
m3_screw_thread_diameter = 3;

m2_screw_pos1 = [usb_case_lip_depth / 2 + wall_depth + m2_4_threaded_insert_diameter, 70];
m2_screw_pos2 = [33.5, 10];

m2_screw_positions = [
  m2_screw_pos1,
  m2_screw_pos2,
];

m3_ear_width = 10;

m3_screw_positions = [
  // [20, -m3_ear_width / 2],
  // [35, usb_case_outer_height + m3_ear_width / 2],
  [usb_case_outer_width + m3_ear_width / 2, usb_case_outer_height / 4],
  [usb_case_outer_width + m3_ear_width / 2, usb_case_outer_height - usb_case_outer_height / 4],
];

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
  usb_case_wall_x_neg,
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
    translate([-usb_case_lip_proud, -usb_case_lip_overhang_y, -usb_case_lip_overhang_z])
      cube(
        [
          usb_case_lip_depth,
          usb_case_outer_height + (usb_case_lip_overhang_y * 2),
          usb_case_depth + (usb_case_lip_overhang_z * 2),
        ]
      );

    // The window. Only the proud half needs clearing — behind x = 0 the collar
    // overlaps solid case body. Its floor is the case's own -x wall, so the ports
    // end up recessed by usb_case_lip_proud - usb_port_lip.
    translate([-usb_case_lip_proud - eps, 0, 0])
      cube([usb_case_lip_proud + (eps * 2), usb_case_outer_height, usb_case_depth]);
  }
}

module usb_case() {
  difference() {
    color("steelblue") {
      difference() {
        cube(
          [
            usb_case_outer_width,
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

// This is the lip that guides the top case into place, ensuring it aligns correctly with the bottom case.
module usb_case_bottom_lip() {
  translate([pcb_pos[0] - tolerance, pcb_pos[1] - tolerance, usb_case_depth / 2 - 1])
    linear_extrude(height=usb_case_bottom_lip_depth)
      difference() {
        difference() {
          square([usb_pcb_width + (tolerance * 2), usb_pcb_height + (tolerance * 2)], center=false);

          offset(delta=-1) square([usb_pcb_width + (tolerance * 2), usb_pcb_height + (tolerance * 2)], center=false);
        }

        //remove the left and top edges of the square so the pcb can fit
        translate([-1, 1, -1])
          square([usb_pcb_width + (tolerance * 2), usb_pcb_height + (tolerance * 2)], center=false);
      }
}

module usb_case_threaded_insert_holes() {
  for (pos = m2_screw_positions)
    translate([pos[0], pos[1], usb_case_depth / 2 - m2_4_threaded_insert_length])
      color("red")
        cylinder(h=m2_4_threaded_insert_length + eps, r=m2_4_threaded_insert_diameter / 2);
}

module usb_case_bottom() {
  difference() {
    union() {
      half_of(v=[0, 0, -1], cp=[0, 0, usb_case_depth / 2], s=1000) usb_case();

      usb_case_bottom_lip();

      translate([m2_screw_pos2[0], m2_screw_pos2[1], usb_case_wall_depth])
        cylinder(h=usb_case_depth / 2 - usb_case_wall_depth, r=m2_4_threaded_insert_diameter);
    }

    // Threaded insert holes
    usb_case_threaded_insert_holes();
  }

  for (pos = m3_screw_positions)
    translate([pos[0], pos[1]]) {
      difference() {

        translate([-m3_ear_width / 2, -m3_ear_width / 2, 0])
          cube([m3_ear_width, m3_ear_width, usb_case_depth / 2 + eps]);

        color("red")
          // cylinder(h=100 + eps, r=m3_6_threaded_insert_diameter / 2);
          translate([0, 0, (usb_case_depth / 2) + eps])
            screw_hole(
              head_depth=(usb_case_depth / 2) - 2,
              head_diameter=m3_screw_head_diameter,
              8,
              m3_screw_thread_diameter,
            );
      }
    }
}

module usb_case_top() {
  difference() {
    union() {
      half_of(cp=[0, 0, usb_case_depth / 2], s=1000) usb_case();

      usb_case_top_screw_mount_depth = 4;
      translate([m2_screw_pos2[0], m2_screw_pos2[1], usb_case_depth - usb_case_wall_depth - usb_case_top_screw_mount_depth])
        cylinder(h=usb_case_top_screw_mount_depth, r=m2_4_threaded_insert_diameter);
    }

    for (pos = m2_screw_positions)
      translate([pos[0], pos[1], usb_case_depth])
        screw_hole(
          head_depth=usb_case_depth / 2 - 2, head_diameter=m2_screw_head_diameter,
          8,
          m2_screw_thread_diameter,
        );
  }
}

cutaway() {
  if (render_top) usb_case_top();
  if (render_bottom) usb_case_bottom();
  if (render_pcb) translate(pcb_pos) pcb();
}

echo("Case width: ", usb_case_width + (usb_case_wall_depth * 2));
