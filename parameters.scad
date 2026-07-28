// ============================================================
// Global rendering
// ============================================================
// Facet quality (global). $fs holds constant surface smoothness across sizes;
// $fa caps facet count on large radii. OpenSCAD uses whichever yields more.
$fa = 1;
$fs = 0.4;

eps = 0.01;

// Fit clearance applied to mating parts.
tolerance = 0.3;

// ============================================================
// Case
// ============================================================

case_split_z = 20;
case_bottom_lip_width = 2;

// This is the depth that sticks out from the top of the bottom half of the case
case_bottom_lip_depth = 2;

case_screw_mount_diameter = 15;
case_screw_mount_width = 30;
case_screw_mount_height = 15;
case_screw_mount_spacing = 11;

// Planning on using M3x8 screws
case_screw_head_depth = 30;
case_screw_head_diameter = 5.35;
case_screw_thread_diameter = 3;
case_screw_thread_length = 8;
case_screw_spacing = 4;

// ============================================================
// Wedge (front-to-back taper)
// ============================================================
wedge_angle = 2;
wedge_slope = tan(wedge_angle);

// inverse the vector, divide by the norm (actual length) inversed vector.
// norm is NOT the normalization, it gets the actual length of the vector,
// and normalizing is dividing a vector by it's length.
wedge_normal = [0, -wedge_slope, 1] / norm([0, -wedge_slope, 1]);

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
// Base dimensions (independent)
// Interior and exterior interconnect, so base values come first,
// then the derived values below.
// ============================================================
exterior_width = 255;
exterior_height = 211;
interior_depth = 28;

// ============================================================
// Derived dimensions
// ============================================================
// Interior <- exterior width/height
interior_width = exterior_width - (wall_depth * 2);
interior_height = exterior_height - (wall_depth * 2);
interior_front_depth = interior_depth;
interior_back_depth = (exterior_height * tan(wedge_angle)) + interior_front_depth;

// Exterior depth <- interior_depth
exterior_front_depth = interior_depth + (top_and_bottom_wall_depth * 2);
exterior_back_depth = (exterior_height * tan(wedge_angle)) + exterior_front_depth;

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

battery_x = interior_width - (battery_pack_width) - 23;
battery_y = interior_height - (battery_pack_height) - 17;

battery_pack_cover_width = battery_pack_width + 6;
battery_pack_cover_height = battery_pack_height + 6;

// ============================================================
// Screen
// ============================================================
screen_width = 84;
screen_height = 84;

// This is the depth of the screen + Pi
// Called it _to_mount because this is the amount of space from the top of the case to the mount posts
screen_depth_to_mount = 24.80;

// Centered in the bay bounded by the left corner screws and the mid-span pair. The USB hub
// keep-out (deck x 0 -> 38.7) notches this plinth's left edge, which is fine, but it also
// covers where the screen's low-x/low-y floor screw pocket would go. That one screw is
// omitted in screen_components.scad rather than shifting the screen off center — moving it
// would decenter the battery too, since the mid screws bound its bay as well.
screen_x = 25;
screen_y = interior_height - (screen_height) - 7;

screen_screw_thread_diameter = 2.5;
screen_screw_head_diameter = 4;
screen_screw_washer_diameter = 5;
screen_screw_thread_length = 8;

// This should include the washer depth as well
screen_screw_head_depth = 3.85;

// ============================================================
// Hub
// ============================================================

// Where the hub sits, in *exterior* deck coords — it does NOT go through
// interior_cutout_translate(), because the case sits square to the deck floor rather than
// following the wedge. Everything hub-related keys off this so the keep-out and the flange
// holes can't drift apart.
//
// x is -usb_deck_face_x (the collar's back face, half of usb_case_lip_depth), which lands the
// flange on the wall's outer surface at x = 0. Written as a literal because cyberdeck.scad
// pulls usb_components.scad in with `use`, so only its modules cross over, not its variables.
usb_hub_pos = [-2, 100, 6];

hub_board_height = 61.45;
hub_board_width = 25.40;
hub_usb_port_width = 13.25;
hub_usb_port_depth = 6;
hub_usb_port_length = 10;

hub_usb_port_mount_height = 7.5;
hub_usb_port_cutout_depth = 10;
