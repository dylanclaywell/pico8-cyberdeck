// ============================================================
// Global rendering
// ============================================================
// Facet quality (global). $fs holds constant surface smoothness across sizes;
// $fa caps facet count on large radii. OpenSCAD uses whichever yields more.
$fa = 1;
$fs = 0.4;

// Fit clearance applied to mating parts.
tolerance = 0.3;

// ============================================================
// Threaded inserts
// ============================================================
threaded_insert_diameter = 5;
threaded_insert_depth = 6;
threaded_insert_vertical_spacing = 2;
threaded_insert_post_diameter = threaded_insert_diameter + 5;

// ============================================================
// Walls
// ============================================================
wall_depth = 5;
top_and_bottom_wall_depth = 3.5;

// ============================================================
// Exterior dimensions
// ============================================================
exterior_width = 255;
exterior_height = 211;

exterior_front_depth = interior_depth + (top_and_bottom_wall_depth * 2);
exterior_back_depth = (exterior_height * tan(wedge_angle)) + exterior_front_depth;

// ============================================================
// Interior dimensions
// ============================================================
interior_width = exterior_width - (wall_depth * 2);
interior_height = exterior_height - (wall_depth * 2);
interior_depth = 28;

interior_front_depth = interior_depth;
interior_back_depth = (exterior_height * tan(wedge_angle)) + interior_front_depth;

// ============================================================
// Wedge (front-to-back taper)
// ============================================================
wedge_angle = 2;

// ============================================================
// Keyboard
// ============================================================
keyboard_width = 230;
keyboard_height = 78;

keyboard_x = (exterior_width / 2) - (keyboard_width / 2) - wall_depth;
keyboard_y = 20;

// ============================================================
// Battery
// ============================================================
battery_pack_width = 87;
battery_pack_height = 63.65;

battery_x = interior_width - (battery_pack_width) - 15;
battery_y = interior_height - (battery_pack_height) - 16;

battery_pack_cover_width = battery_pack_width + 6;
battery_pack_cover_height = battery_pack_height + 6;


// ============================================================
// Screen
// ============================================================
screen_width = 60;
screen_height = 60;

screen_x = 20;
screen_y = interior_height - (screen_height) - 20;