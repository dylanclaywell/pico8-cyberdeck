debug = false;

tolerance = 0.3;

threaded_insert_diameter = 6;

wall_depth = 5;
top_and_bottom_wall_depth = 3.5;

exterior_width = 255;
exterior_height = 211;

interior_width = exterior_width - (wall_depth * 2);
interior_height = exterior_height - (wall_depth * 2);
interior_depth = 28;

wedge_angle = 2;

interior_front_depth = interior_depth;
interior_back_depth = (exterior_height * tan(wedge_angle)) + interior_front_depth;

exterior_front_depth = interior_depth + (top_and_bottom_wall_depth * 2);
exterior_back_depth = (exterior_height * tan(wedge_angle)) + exterior_front_depth;

threaded_insert_post_diameter = threaded_insert_diameter + 5;

keyboard_width = 230;
keyboard_height = 78;

keyboard_x = (exterior_width / 2) - (keyboard_width / 2) - wall_depth;
keyboard_y = 20;

battery_pack_width = 87;
battery_pack_height = 63.65;

battery_x = interior_width - (battery_pack_width) - 15;
battery_y = interior_height - (battery_pack_height) - 16;

battery_pack_cover_width = battery_pack_width + 6;
battery_pack_cover_height = battery_pack_height + 6;


// These are relative to the keyboard position
keyboard_post_positions = [
    // top left
    [20.25, keyboard_height - 9.25],
    
    // top middle
    [96.50, keyboard_height - 9.25],
    
    // top right
    [keyboard_width - 20.25, keyboard_height - 9.25],
    
    // bottom left
    [20.25, 11.25],
    
    // bottom middle
    [keyboard_width - 96.50, 11.25],
    
    // bottom right
    [keyboard_width - 20.25, 11.25]
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

module interior_cutout_translate() {
    translate([wall_depth, wall_depth, exterior_front_depth - interior_depth - top_and_bottom_wall_depth + (wall_depth * tan(wedge_angle))])
        rotate([wedge_angle, 0, 0])
            children();
}

module chamfer(position=[0, 0, 0], angle=[45, 0, 0], size=[10, 10, 10]) {
    difference() {
        children();
        translate(position)
            rotate(angle)
            cube([size[0]*2, size[1]*2, size[2]*2], center=true);
    }
}

module cutaway() {
    difference() {
        children();
        
        if (debug)
            translate([-1, 10, 0])
                cube([300, 100, 300]);
    }
}

module battery_cover() {
    interior_cutout_translate() {
        translate([battery_x - 3, battery_y - 3 , interior_depth + top_and_bottom_wall_depth / 2]) {
            difference() {
                cube([battery_pack_cover_width, battery_pack_cover_height, top_and_bottom_wall_depth / 2]);
                
                translate([2, 2, -1])
                    cube([battery_pack_cover_width - 4, battery_pack_cover_height - 4, 4]);
            }
        }
    }
}

module battery_posts() {
    for (i = battery_post_positions) {
        x = i[0];
        y = i[1];
        translate([x, y, 0])
            color("yellow")
            cylinder(h=10, r1=threaded_insert_post_diameter / 2, r2=(threaded_insert_post_diameter - 1) / 2);
    }
}

module battery_mount() {
  interior_cutout_translate() {
    translate([battery_x, battery_y, ]) {
        %cube([battery_pack_width, battery_pack_height, 10]);
        
        battery_posts();
    }
  }
}

module battery_cutout() {
    interior_cutout_translate() {
        translate([battery_x - 3 - tolerance, battery_y - 3 - tolerance, 0]) {
            cube([battery_pack_cover_width + (tolerance * 2), battery_pack_cover_height + (tolerance * 2), 100]);
        }
    }  
}

module keyboard_posts() {
    for (i = keyboard_post_positions) {
        x = i[0];
        y = i[1];
        translate([x, y, 0])
            color("yellow")
            cylinder(h=10, r1=threaded_insert_post_diameter / 2, r2=(threaded_insert_post_diameter - 1) / 2);
    }
}

module keyboard_mount() {
    interior_cutout_translate() {
        translate([keyboard_x, keyboard_y, 0]) {
            keyboard_posts();
        }
    }
}

module keyboard_cutout() {
    interior_cutout_translate() {
        translate([keyboard_x, keyboard_y, 0]) {
            cube([keyboard_width, keyboard_height, 80]);
        }
    }
}

module body() {
    cutaway() {
        difference() {
            difference() {
                hull() {
                    cube([exterior_width, 0.1, exterior_front_depth]);
                    translate([0, exterior_height, 0])
                        cube([exterior_width, 0.1, exterior_back_depth]);
                }
                color("blue", 0.25)
                    translate([wall_depth, wall_depth, exterior_front_depth - interior_depth - top_and_bottom_wall_depth])
                        rotate([wedge_angle, 0, 0])
                            cube([interior_width, interior_height, interior_depth]);
            }
            keyboard_cutout();
            battery_cutout();
        }
    }
    
    keyboard_mount();
    battery_mount();
    battery_cover();
}

body();

echo("Hello", exterior_front_depth, exterior_back_depth);