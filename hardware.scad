include <parameters.scad>

// Negative solid for a cylindrical-head (counterbore) screw.
// Origin = the surface the head sits flush with; the hole descends in -z.
// The thread shaft exits the bottom (through-hole), with a small overshoot
// on both ends so no cut face sits coincident with a surface.
module screw_hole(head_depth, head_diameter, thread_length, thread_diameter) {
    eps = 0.01;

    // head counterbore (breaks the top surface)
    translate([0, 0, -head_depth])
        cylinder(h = head_depth + eps, r = head_diameter / 2 + tolerance);

    // thread clearance shaft (overlaps the head, exits the bottom)
    translate([0, 0, -(head_depth + thread_length) - eps])
        cylinder(h = thread_length + (eps * 2), r = thread_diameter / 2 + tolerance);
}
