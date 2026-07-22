include <parameters.scad>

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
            cylinder(h=10, r1=threaded_insert_post_diameter / 2, r2=(threaded_insert_post_diameter - 1) / 2);
    }
}

module battery_mount(position = [0, 0, 0]) {
    cube([battery_pack_width, battery_pack_height, 10]);

    battery_posts();
}

module battery_cover() {
    difference() {
        cube([battery_pack_cover_width, battery_pack_cover_height, top_and_bottom_wall_depth / 2]);

        translate([2, 2, -1])
            cube([battery_pack_cover_width - 4, battery_pack_cover_height - 4, 4]);
    }
}

module battery_cutout() {
    cube([battery_pack_cover_width + (tolerance * 2), battery_pack_cover_height + (tolerance * 2), 100]);
}

%battery_cutout();
battery_mount();
translate([200, 0, 0]) battery_cover();
