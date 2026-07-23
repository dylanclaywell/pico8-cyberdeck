include <parameters.scad>

use <hardware.scad>

battery_cover_ear_radius = 8;
battery_cutout_depth = exterior_back_depth + 2;
battery_cover_ear_overlap = 2;  // how far ears tuck under the plate
battery_cover_lip = 2;          // cover inner-pocket wall thickness
battery_mount_height = 10;      // mount block / post height

// Planning on using M3*6 screws
battery_cover_screw_head_depth = 3;
battery_cover_screw_head_diameter = 5.35;
battery_cover_screw_thread_diameter = 3;
battery_cover_screw_thread_length = 6;

// Ear (screw-mount) centers, relative to the cover origin. Shared by the ear
// geometry and the screw holes so they can't drift apart.
battery_cover_ear_y = battery_pack_cover_height / 2;
battery_cover_ear_x = [
    -battery_cover_ear_radius + battery_cover_ear_overlap,
    battery_cover_ear_radius + battery_pack_cover_width - battery_cover_ear_overlap
];

// These are relative to the battery position
battery_post_positions = [
    // top left
    [26, battery_pack_height - 3.3],

    // top right
    [battery_pack_width - 3.3, battery_pack_height - 3.3],

    // bottom left
    [26, 10.75],

    // bottom right
    [battery_pack_width - 3.3, 10.75]
];

module battery_posts() {
    for (i = battery_post_positions) {
        x = i[0];
        y = i[1];
        translate([x, y, 0])
            color("yellow")
            cylinder(h=battery_mount_height, r1=threaded_insert_post_diameter / 2, r2=(threaded_insert_post_diameter - 1) / 2);
    }
}

module battery_mount(position = [0, 0, 0]) {
    cube([battery_pack_width, battery_pack_height, battery_mount_height]);

    battery_posts();
}

// --- Cover (2D profile -> extrude) ---------------------------------------

module battery_cover_plate() {
    square([battery_pack_cover_width, battery_pack_cover_height]);
}

module battery_cover_ears() {
    // rounded end caps, centered on the shared ear positions
    for (x = battery_cover_ear_x)
        translate([x, battery_cover_ear_y])
            circle(battery_cover_ear_radius);

    // left ear neck back to the plate
    translate([battery_cover_ear_x[0], battery_cover_ear_y - battery_cover_ear_radius])
        square([battery_cover_ear_radius, battery_cover_ear_radius * 2]);

    // right ear neck back to the plate
    translate([battery_pack_cover_width - battery_cover_ear_overlap, battery_cover_ear_y - battery_cover_ear_radius])
        square([battery_cover_ear_radius, battery_cover_ear_radius * 2]);
}

module battery_cover_profile() {
    battery_cover_plate();
    battery_cover_ears();
}

module battery_cover() {
    difference() {
        linear_extrude(top_and_bottom_wall_depth)
            difference() {
                battery_cover_profile();
                offset(delta = -battery_cover_lip) battery_cover_plate();
            }

        // screw holes through both ears, heads flush with the top face
        for (x = battery_cover_ear_x)
            translate([x, battery_cover_ear_y, top_and_bottom_wall_depth])
                screw_hole(battery_cover_screw_head_depth,
                           battery_cover_screw_head_diameter,
                           battery_cover_screw_thread_length,
                           battery_cover_screw_thread_diameter);
    }
    
    translate([0, 0, top_and_bottom_wall_depth / 2])
    linear_extrude(top_and_bottom_wall_depth / 2)
        difference() {
            offset(delta = -battery_cover_lip) battery_cover_plate();
            offset(delta = -4) battery_cover_plate();
        }
}

// --- Cutout --------------------------------------------------------------

module battery_cutout() {
    linear_extrude(battery_cutout_depth) {
        offset(delta = tolerance) battery_cover_profile();
    }
}

// --- Cover Mount ---------------------------------------------------------

module battery_cover_mount_plate() {
    difference() {
        offset(delta=2) square([battery_pack_cover_width, battery_pack_cover_height]);
        offset(delta=-2) square([battery_pack_cover_width, battery_pack_cover_height]);
    }
}

module battery_cover_mount_ears() {
    for (x = battery_cover_ear_x)
        translate([x, battery_cover_ear_y])
            square(battery_cover_ear_radius * 2, center=true);
}

module battery_cover_mount_ear_holes() {
    for (x = battery_cover_ear_x)
        translate([x, battery_cover_ear_y, threaded_insert_vertical_spacing + 0.01])
            cylinder(h = threaded_insert_depth, r = threaded_insert_diameter / 2);
}

module battery_cover_mount() {
    difference() {
        linear_extrude(threaded_insert_depth + threaded_insert_vertical_spacing) {
            battery_cover_mount_plate();
            battery_cover_mount_ears();
        }
        
        battery_cover_mount_ear_holes();
    }
}

// --- Solo preview (ignored on `use`) -------------------------------------

translate([-200, 0, 0]) %battery_cutout();
battery_mount();
translate([200, 0, 0]) battery_cover();
translate([400, 0, 0]) battery_cover_mount();
