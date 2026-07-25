include <parameters.scad>

keyboard_mount_height = 10;

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

module keyboard_posts() {
    for (i = keyboard_post_positions) {
        x = i[0];
        y = i[1];
        translate([x, y, 0])
            color("yellow")
            
            difference() {
                    cylinder(h=keyboard_mount_height, r1=threaded_insert_post_diameter / 2, r2=(threaded_insert_post_diameter - 1) / 2);
                    translate([0, 0, keyboard_mount_height - threaded_insert_depth]) cylinder(h=threaded_insert_depth + eps, r=threaded_insert_diameter / 2);
                }
            
            
    }
}

module keyboard_mount(position = [0, 0, 0]) {
    keyboard_posts();
}

module keyboard_cutout(position = [0, 0, 0], size = [0, 0, 0]) {
    cube([keyboard_width, keyboard_height, 80]);
}

%keyboard_cutout();
keyboard_mount();