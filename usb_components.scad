include <parameters.scad>

usb_case_width = 27;
usb_case_height = 63;

// The amount of space between the bottom of the PCB and the bottom of the interior of the case
usb_case_bottom_interior_depth = 2.25;
usb_case_top_interior_depth = 7 - 1.6;

usb_pcb_depth = 1.6;
usb_pcb_width = 25.5;
usb_pcb_height = 61.5;

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

module pcb() {
  color("chocolate")
    linear_extrude(height=usb_pcb_depth)
      offset(delta=tolerance)
        difference() {
          square([usb_pcb_width, usb_pcb_height]);

          translate([usb_cutout_pos, -eps, -eps]) square([usb_x_cutout_depth + eps, usb_y_cutout_depth]);
        }

  color("silver")
    translate([0, 5, usb_pcb_depth]) {
      for (i = [0:2]) {
        linear_extrude(height=usb_port_depth)
          translate([-(usb_port_length), i * (usb_port_width + usb_port_gap), 0])
            square([usb_port_length + usb_port_overlap, usb_port_width]);
      }
    }
}

module usb_case() {
  // The case needs to have a wall of 2mm around the PCB, so we need to add that to the width and height of the case

  color("lightgray")
    difference() {
      cube([usb_case_width, usb_case_height, usb_case_bottom_interior_depth + usb_case_top_interior_depth]);
    }
}

//usb_case();
translate(
  [
    usb_case_width / 2 - usb_pcb_width / 2,
    usb_case_height / 2 - usb_pcb_height / 2,
    usb_case_bottom_interior_depth,
  ]
) pcb();
