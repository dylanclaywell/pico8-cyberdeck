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
render_cutout = true;

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
// Whole connector body, overlap included. NOT the stick-out.
usb_port_length = 13.9;
usb_port_width = 13.2;
usb_port_depth = 6;
usb_port_gap = 5.85;
usb_port_lip = 1;

// Stick-out past the board edge. Read by usb_port_shroud_depth and usb_ports().
// Using usb_port_length here by itself instead grows the case by the overlap.
usb_port_protrusion = usb_port_length - usb_port_overlap;

usb_case_wall_depth = 2;
usb_case_width = usb_pcb_width + (usb_case_wall_depth * 2);
usb_case_height = usb_pcb_height + (usb_case_wall_depth * 2);
usb_case_depth = usb_pcb_depth + usb_case_bottom_interior_depth + usb_case_top_interior_depth + (usb_case_wall_depth * 2);

usb_case_bottom_lip_depth = 3;
usb_case_bottom_lip_width = 1;

// How far the case runs past its normal wall to shroud the ports. The case
// face stops where the port's flare begins, so every port sits proud by
// usb_port_lip. Same on both port faces, so they can't drift apart.
usb_port_shroud_depth = usb_port_protrusion - usb_case_wall_depth - usb_port_lip;

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

usb_case_cable_hole_diameter = 8;
usb_case_cable_hole_pos = [usb_case_outer_width, 25, usb_case_depth / 2];

m2_4_threaded_insert_length = 3.9;
m2_4_threaded_insert_diameter = 3.33;
m2_screw_head_diameter = 3.7;
m2_screw_thread_diameter = 2;

m3_6_threaded_insert_length = 6;
m3_6_threaded_insert_diameter = 4;
m3_screw_head_diameter = 5.5;
m3_screw_thread_diameter = 3;

// Stop lip. Bears on the *outer* face of the cyberdeck wall, so the hub drops
// in from outside and can go no deeper. Flange screws through the y overhang land
// in nuts on the wall's inner face and stop it being pulled back out.
usb_case_lip_depth = 4;
// The y overhang carries the flange screw heads, not just bearing surface, so it has
// to fit a head plus material either side of it. The z overhang only ever bears.
usb_case_lip_overhang_y = m3_screw_head_diameter + 4;
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

// This is intentionally "wall_depth", i.e. the cyberdeck case wall depth.
// This way the screw positions do not interfere with the wall of the deck.
m2_screw_pos1 = [usb_case_lip_depth / 2 + wall_depth + m2_4_threaded_insert_diameter, 68];
m2_screw_pos2 = [29.5, 10];

m2_screw_positions = [
  m2_screw_pos1,
  m2_screw_pos2,
];

// Flange screws, as [y, z] — the axis is +x, through the collar and the deck wall into
// a hex nut on the wall's inner face. This replaces the old +x mounting ears, which
// cost 10mm on the tightest axis to resist pull-out 38mm deeper than necessary.
//
// z can't be usb_case_depth / 2 — the collar spans the top/bottom split there and a screw
// centered on it would be half in each part. It also can't be in the bottom half: the deck's
// interior floor is skewed while these two holes share one z, and over the 86mm between them
// the floor climbs 3mm, which buries the +y hole in a bottom wall 9.8mm thick with nowhere to
// seat its nut. So both live in the TOP half, clear of the floor at either y. The hub's top
// half bolts to the deck and the bottom half hangs from it on the m2 screws.
//
// The + 1 pushes the counterbore off the split: the head is m3_screw_head_diameter / 2 plus
// tolerance in radius, so at exactly 3/4 depth it would come within 0.35mm of the seam.
usb_flange_screw_inset = usb_case_lip_overhang_y / 2;

usb_flange_screw_positions = [
  [-usb_flange_screw_inset, (usb_case_depth / 4 * 3) + 1],
  [usb_case_outer_height + usb_flange_screw_inset, (usb_case_depth / 4 * 3) + 1],
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
//
// A port straddles the board edge it's soldered to. Along its own axis it spans
// usb_port_length: usb_port_overlap of that on the board side of the edge,
// usb_port_protrusion on the air side. Outboard is -x for the side ports and +y
// for the far one, so which end is negative differs per port.
module usb_ports(t = 0) {
  // Three side ports, facing -x. Clearance is applied on the -x face too, so
  // the pocket keeps clearing the front slab even if usb_port_lip changes.
  for (i = [0:2])
    translate([-usb_port_protrusion - t, 5 + i * (usb_port_width + usb_port_gap) - t, -t])
      cube([usb_port_length + (t * 2), usb_port_width + (t * 2), usb_port_depth + (t * 2)]);

  // One port on the far edge, facing +y.
  translate([usb_port_overlap - t, usb_pcb_height - usb_port_overlap - t, -t])
    cube([usb_port_width + (t * 2), usb_port_length + (t * 2), usb_port_depth + (t * 2)]);
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

    // Flange screw holes. screw_hole() descends in -z from the face the head sits flush
    // with, so rotate -z onto +x: head flush with the collar's outer face, shaft running
    // on through the deck wall to a nut behind it.
    for (pos = usb_flange_screw_positions)
      translate([-usb_case_lip_proud, pos[0], pos[1]])
        rotate([0, -90, 0])
          color("red")
            screw_hole(
              head_depth=usb_case_lip_proud,
              head_diameter=m3_screw_head_diameter,
              usb_case_lip_depth,
              m3_screw_thread_diameter,
            );
  }
}

module usb_case_base() {
  difference() {
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
}

// The lip that aligns the top half to the bottom. Two runs standing on the split face,
// OUTBOARD of the board pocket. It used to be a ring inset usb_case_bottom_lip_width INTO
// the pocket, which left a 25.1 x 61.1 window over a 25.5 x 61.5 board: the board could not
// be lowered in, only wedged, and it landed port side high.
//
// Only -x and +y carry a run. Those walls are shroud-thick, while +x and -y are bare
// usb_case_wall_depth and a run plus its groove would leave them a 0.6mm skin. The -x run
// lies along y so it stops x drift, the +y run lies along x so it stops y drift, so dropping
// the other two costs no registration.
//
// t grows the runs into the groove usb_case_top() cuts, so lip and groove can't disagree.
module usb_case_bottom_lip(t = 0) {
  pocket_x = pcb_pos[0] - tolerance;
  pocket_y = pcb_pos[1] - tolerance;
  pocket_w = usb_pcb_width + (tolerance * 2);
  pocket_h = usb_pcb_height + (tolerance * 2);
  w = usb_case_bottom_lip_width;

  difference() {
    union() {
      // -x run, along y. Overruns the pocket by w at both ends to meet the +y run.
      translate([pocket_x - w - t, pocket_y - w - t, usb_case_depth / 2 - t])
        cube([w + (t * 2), pocket_h + (w * 2) + (t * 2), usb_case_bottom_lip_depth + (t * 2)]);

      // +y run, along x.
      translate([pocket_x - w - t, pocket_y + pocket_h - t, usb_case_depth / 2 - t])
        cube([pocket_w + (w * 2) + (t * 2), w + (t * 2), usb_case_bottom_lip_depth + (t * 2)]);
    }

    // Both runs cross port bores, so what survives on -x is the material between the side
    // ports and on +y the material either side of the far one.
    //
    // The clearance shrinks as t grows: at t = 0 the lip segments stop tolerance short of the
    // bore walls, at t = tolerance the groove segments reach them. Subtracting the same bore
    // for both would butt the segment ends together in y with nothing between them.
    translate(pcb_pos) usb_ports((tolerance * 2) - t);
  }
}

module usb_case_threaded_insert_holes() {
  for (pos = m2_screw_positions)
    translate([pos[0], pos[1], usb_case_depth / 2 - m2_4_threaded_insert_length])
      color("red")
        cylinder(h=m2_4_threaded_insert_length + eps, r=m2_4_threaded_insert_diameter / 2);
}

module usb_case_cable_hole() {
  // Cable hole
  translate(
    [
      usb_case_cable_hole_pos[0] - usb_case_wall_depth - usb_case_bottom_lip_depth,
      usb_case_cable_hole_pos[1],
      usb_case_cable_hole_pos[2] - eps,
    ]
  )
    rotate([0, 90, 0])
      cylinder(h=usb_case_depth + (eps * 2), r=usb_case_cable_hole_diameter / 2);
}

module usb_case_bottom() {
  difference() {
    difference() {
      union() {
        half_of(v=[0, 0, -1], cp=[0, 0, usb_case_depth / 2], s=1000) usb_case_base();

        usb_case_bottom_lip();

        translate([m2_screw_pos2[0], m2_screw_pos2[1], usb_case_wall_depth])
          cylinder(h=usb_case_depth / 2 - usb_case_wall_depth, r=m2_4_threaded_insert_diameter);
      }

      // Threaded insert holes
      usb_case_threaded_insert_holes();
    }

    usb_case_cable_hole();
  }
}

// Keep-out volume for the hub: everything the case occupies once it's seated. Not a
// wall hole — the case sits square to the deck floor while the deck interior is skewed,
// so this carves a channel through whatever it passes. Starts at usb_deck_face_x: the
// collar stays outside and bears on the deck's outer face there, so that plane must keep
// its material, and the flange overhang sits clear of this footprint entirely.
//
// MUST be placed outside interior_cutout_translate(), unlike every other cutout in
// case_cutouts() — inheriting the wedge skew would tilt the hub off the case bottom.
// The hub's own origin sits usb_deck_face_x proud of the wall, so place it at
// -usb_deck_face_x to land the collar on a deck exterior face at x = 0.
// The +y run carries usb_port_lip on top of the case face: that port stands proud of its
// wall exactly like the side ports do on -x. The side ports point along the insertion slide
// so they lead the way, but this one is broadside to it, and 1mm of flange over 38mm of
// travel stops the case entering at all. The collar overhangs +y by usb_case_lip_overhang_y,
// so the extra hole stays hidden behind the flange.
module usb_case_cutout(t = tolerance) {
  translate([usb_deck_face_x - eps, -t, -t])
    cube(
      [
        usb_case_outer_width - usb_deck_face_x + eps + t,
        usb_case_outer_height + usb_port_lip + (t * 2),
        usb_case_depth + (t * 2),
      ]
    );
}

// The deck-side half of the flange fastening: one clearance hole per flange screw, bored +x
// through the wall the collar bears on, for a bolt captured by a hex nut on the inner face.
//
// Reads usb_flange_screw_positions, the same list usb_case_lip() drills, so the two halves
// can't disagree. Place it with the SAME translate as usb_case_cutout() — it's in the hub's
// frame, not the wall's.
//
// `through` is wall_depth PLUS the bottom lip: these screws sit low enough to land in the
// clamshell lip, which stands case_bottom_lip_depth inboard of the wall so the bottom half
// prints without supports. A bare wall_depth bore stops 2mm short of daylight. Overshoot is
// free — past the lip it's interior air.
module usb_case_flange_holes(t = tolerance, through = wall_depth + tolerance + case_bottom_lip_depth) {
  for (pos = usb_flange_screw_positions)
    translate([usb_deck_face_x - eps, pos[0], pos[1]])
      rotate([0, 90, 0])
        color("red")
          cylinder(h=through + (eps * 2), r=m3_screw_thread_diameter / 2 + t);
}

module usb_case_top() {
  difference() {
    difference() {
      union() {
        half_of(cp=[0, 0, usb_case_depth / 2], s=1000) usb_case_base();

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

    usb_case_cable_hole();

    // Groove for usb_case_bottom_lip(). Same module the bottom half adds, grown by tolerance.
    usb_case_bottom_lip(tolerance);
  }
}

cutaway() {
  if (render_top) usb_case_top();
  if (render_bottom) usb_case_bottom();
  if (render_pcb) translate(pcb_pos) pcb();
}

module usb_case() {
  usb_case_top();
  usb_case_bottom();
}

echo("Case width: ", usb_case_width + (usb_case_wall_depth * 2));

if (render_cutout)
  translate([100, 0, 0]) %usb_case_cutout(tolerance);
  translate([100, 0, 0]) %usb_case_cutout(tolerance);
