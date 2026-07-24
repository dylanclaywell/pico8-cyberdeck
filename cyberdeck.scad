include <BOSL2/std.scad>
include <parameters.scad>

use <keyboard_components.scad>
use <battery_components.scad>
use <screen_components.scad>

debug = false;

module interior_cutout_translate() {
    skew(szy=tan(wedge_angle))
        translate([wall_depth, wall_depth, top_and_bottom_wall_depth])
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
                cube([300, 150, 300]);
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
                color("blue")
                    interior_cutout_translate()
                        cube([interior_width, interior_height, interior_depth]);
            }
            interior_cutout_translate() {
                translate([keyboard_x, keyboard_y, 0]) keyboard_cutout([keyboard_x, keyboard_y, 0], [keyboard_width, keyboard_height, 80]);
                translate([battery_x - 3, battery_y - 3, 0]) battery_cutout();
            }
        }
    }
    
    interior_cutout_translate() {
        translate([keyboard_x, keyboard_y, 0]) keyboard_mount();
        translate([battery_x, battery_y, 0]) battery_mount();
        translate([battery_x - 3, battery_y - 3, interior_depth]) battery_cover();
        translate([battery_x - 3, battery_y - 3, interior_depth - threaded_insert_depth - threaded_insert_vertical_spacing]) battery_cover_mount();
    }
}

body();

echo("Hello", exterior_front_depth, exterior_back_depth);