// Adapter enclosure for fitting a Shelly Mini behind the lower body of a wall switch.
//
// Intended for switches like the AliExpress "smart switch" type where the lower housing
// holds the button mechanism and wiring. The original lower body slides into the adapter
// from below; the button passes through a capsule opening in the top; the Shelly Mini
// sits underneath; and a removable bottom lid closes the enclosure.
//
// Product reference (example switch): https://es.aliexpress.com/item/1005003104818994.html

// What to preview or export: "assembly", "upper_shell", "bottom_lid", or "exploded". "assembly", "upper_shell", "bottom_lid", or "exploded".
render_part = "exploded";

// Show a blue Shelly Mini in the preview so you can see where the device sits (not printed).
show_shelly_reference = true;

// Smooth edge rounding
$fn = 50;

// Small epsilon to avoid SCAD Z-fighting (explained at https://en.wikipedia.org/wiki/Z-fighting)
eps = 0.01;

// Lower switch housing — the part you keep from the original switch (button + wiring).
switch_body_length = 60; // mm
switch_body_width = 26; // mm
switch_body_height = 9; // mm
switch_body_corner_radius = 2.5; // mm
fit_clearance = 0.3; // mm per side; increase if the switch body is too tight

// Shelly Mini device.
shelly_length = 33.5; // mm
shelly_width = 28; // mm
shelly_height = 16.6; // mm
shelly_clearance = 0.6; // mm per side around the Shelly
wire_clearance = 3; // mm; gap above the Shelly for switch wiring

// Printed enclosure.
wall_thickness = 1.5; // mm
top_thickness = 1.5; // mm; solid top that stops the switch body and surrounds the button hole
floor_clearance = 3; // mm; room below the Shelly for the lid lip
corner_radius = 4; // mm
cavity_corner_radius = switch_body_corner_radius + fit_clearance;

// Removable bottom lid.
lid_thickness = 1.5; // mm
lid_lip_height = 2; // mm; raised edge that seats inside the bottom opening
lid_fit_clearance = 0.25; // mm per side for an easy lid fit

// Lid rails that keep the Shelly from sliding lengthwise (wire sides stay open).
shelly_guide_width = 0.8; // mm
shelly_guide_height = 5; // mm
shelly_guide_length = shelly_width - 4;
shelly_guide_clearance = 0.25; // mm

// Capsule-shaped opening in the top for the switch button.
button_hole_length = 20; // mm
button_hole_width = 12; // mm

// Wire pass-throughs on both short sides of the enclosure.
cable_hole_diameter = 4; // mm

// Four locating pins that enter the corner holes on the switch lower body.
// Measure your switch and adjust the inset values to match the hole positions.
switch_mount_post_diameter = 2.4; // mm
switch_mount_post_height = 2.5; // mm
switch_mount_post_x_inset = 5; // mm from each short end to hole center
switch_mount_post_y_inset = 5; // mm from each long side to hole center

// Side ribs that center the narrower switch body in the wider Shelly-sized cavity.
switch_centering_rib_depth = min(0.8, (shelly_width - switch_body_width) / 2);
switch_centering_rib_height = switch_body_height - 1;
switch_centering_rib_length = switch_body_length - 10;

switch_cavity_length = switch_body_length + (2 * fit_clearance);
switch_cavity_width = switch_body_width + (2 * fit_clearance);
switch_cavity_height = switch_body_height + fit_clearance;

shelly_cavity_length = shelly_length + (2 * shelly_clearance);
shelly_cavity_width = shelly_width + (2 * shelly_clearance);
shelly_cavity_height = shelly_height + (2 * shelly_clearance);
shelly_guided_length = shelly_length + (2 * (shelly_guide_clearance + shelly_guide_width));

inner_length = max(switch_cavity_length, shelly_cavity_length, shelly_guided_length);
inner_width = max(switch_cavity_width, shelly_cavity_width);
inner_height = switch_cavity_height + wire_clearance + shelly_cavity_height + floor_clearance;

outer_length = inner_length + (2 * wall_thickness);
outer_width = inner_width + (2 * wall_thickness);
outer_height = top_thickness + inner_height;

z_top = 0;
z_switch_top = z_top - top_thickness;
z_switch_bottom = z_switch_top - switch_cavity_height;
z_shelly_top = z_switch_bottom - wire_clearance;
z_shelly_bottom = z_shelly_top - shelly_cavity_height;
z_outer_bottom = z_shelly_bottom - floor_clearance;

cable_hole_z = (z_shelly_top + z_shelly_bottom) / 2;

module rounded_rect(length, width, r) {
  offset(r = r)
    square([length - (2 * r), width - (2 * r)], center = true);
}

module rounded_box_between(z_from, z_to, length, width, r) {
  translate([0, 0, z_from])
    linear_extrude(height = z_to - z_from)
      rounded_rect(length, width, r);
}

module capsule_2d(length, width) {
  hull()
    for (x_side = [-1, 1])
      translate([x_side * ((length - width) / 2), 0])
        circle(d = width);
}

module outer_body() {
  rounded_box_between(z_outer_bottom, z_top, outer_length, outer_width, corner_radius);
}

// Hollow interior, open at the bottom for loading the switch and Shelly.
module interior_cavity() {
  rounded_box_between(
    z_outer_bottom - eps,
    z_switch_top + eps,
    inner_length,
    inner_width,
    cavity_corner_radius
  );
}

// Preview-only blue stand-in for the Shelly Mini (not printed).
module shelly_reference() {
  color("blue", 0.75)
    rounded_box_between(
      z_shelly_top - shelly_clearance - shelly_height,
      z_shelly_top - shelly_clearance,
      shelly_length,
      shelly_width,
      2
    );
}

// Capsule-shaped hole in the top face for the switch button.
module button_opening() {
  translate([0, 0, z_switch_top - eps])
    linear_extrude(height = top_thickness + (2 * eps))
      capsule_2d(button_hole_length, button_hole_width);
}

// Side opening for wiring on the given short end.
module cable_passage(x_side) {
  translate([
    x_side * (outer_length / 2 - wall_thickness / 2),
    0,
    cable_hole_z
  ])
    rotate([0, 90, 0])
      cylinder(
        d = cable_hole_diameter,
        h = wall_thickness + (2 * eps),
        center = true
      );
}

// Side rails that center the switch body in the wider cavity.
module switch_centering_ribs() {
  if (switch_centering_rib_depth > 0) {
    for (y_side = [-1, 1]) {
      translate([
        0,
        y_side * ((inner_width / 2) - (switch_centering_rib_depth / 2) + eps),
        (z_switch_top + z_switch_bottom) / 2
      ])
        cube([
          switch_centering_rib_length,
          switch_centering_rib_depth,
          switch_centering_rib_height
        ], center = true);
    }
  }
}

// Four pins that enter the corner holes on the switch lower body.
module switch_retention_posts() {
  post_x = (switch_body_length / 2) - switch_mount_post_x_inset;
  post_y = (switch_body_width / 2) - switch_mount_post_y_inset;

  for (x_side = [-1, 1]) {
    for (y_side = [-1, 1]) {
      translate([
        x_side * post_x,
        y_side * post_y,
        z_switch_top - switch_mount_post_height + eps
      ])
        cylinder(
          d = switch_mount_post_diameter,
          h = switch_mount_post_height
        );
    }
  }
}

// Main printed part: outer shell, button hole, cable exits, and switch locators.
module upper_shell() {
  union() {
    difference() {
      outer_body();
      interior_cavity();
      button_opening();

      for (x_side = [-1, 1])
        cable_passage(x_side);
    }

    switch_centering_ribs();
    switch_retention_posts();
  }
}

// Raised edge on the lid that seats inside the bottom opening.
module lid_alignment_lip() {
  rounded_box_between(
    z_outer_bottom,
    z_outer_bottom + lid_lip_height,
    inner_length - (2 * lid_fit_clearance),
    inner_width - (2 * lid_fit_clearance),
    max(cavity_corner_radius - lid_fit_clearance, 0.1)
  );
}

// Flat bottom cover plate.
module lid_plate() {
  rounded_box_between(
    z_outer_bottom - lid_thickness,
    z_outer_bottom,
    outer_length,
    outer_width,
    corner_radius
  );
}

// Two rails on the lid that stop the Shelly Mini from sliding lengthwise.
module shelly_lid_guides() {
  guide_x = (shelly_length / 2) + shelly_guide_clearance + (shelly_guide_width / 2);

  for (x_side = [-1, 1]) {
    translate([
      x_side * guide_x,
      0,
      z_outer_bottom + (shelly_guide_height / 2)
    ])
      cube([
        shelly_guide_width,
        shelly_guide_length,
        shelly_guide_height
      ], center = true);
  }
}

// Removable cover that closes the bottom of the enclosure.
module bottom_lid() {
  union() {
    lid_plate();
    lid_alignment_lip();
    shelly_lid_guides();
  }
}

module assembled_adapter() {
  upper_shell();
  bottom_lid();

  if (show_shelly_reference)
    shelly_reference();
}

module exploded_adapter() {
  upper_shell();

  translate([0, 0, -8])
    bottom_lid();

  if (show_shelly_reference)
    shelly_reference();
}

if (render_part == "upper_shell") {
  upper_shell();

  if (show_shelly_reference)
    shelly_reference();
} else if (render_part == "bottom_lid") {
  translate([0, 0, outer_height + lid_thickness])
    bottom_lid();
} else if (render_part == "exploded") {
  exploded_adapter();
} else {
  assembled_adapter();
}
