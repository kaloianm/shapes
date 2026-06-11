// Replacement/customizable cover tile for a Gira Pushbutton Sensor.
//
// This prints the small insert/cover shown in the reference photo: a shallow tray with raised end
// lips and two retaining arch clips. Intended to fit the Gira Pushbutton Sensor 3 Komfort family,
// including the 3-gang KNX variant documented by Gira as item no. 5133 00.
//
// Product reference: https://katalog.gira.de/en-INT/datenblatt/4010337086857

// Smooth edge rounding
$fn = 50;

// Small epsilon to avoid SCAD Z-fighting (explained at https://en.wikipedia.org/wiki/Z-fighting)
eps = 0.01;

// Outer box dimensions
outer_length = 54.5; // mm
outer_width = 18.5; // mm
outer_height = 2; // mm

// Inner box dimensions. The recessed area leaves a 1 mm perimeter wall and a 1 mm tray floor.
inner_length = 52.5; // mm
inner_width = 16.5; // mm
inner_depth = 1; // mm

wall_thickness = (outer_length - inner_length) / 2;

side_piece_depth = wall_thickness;
side_piece_height = 0.5; // mm

// Retaining arches on the short sides. The lower leg corners stay square;
// only the two outside top corners are rounded to soften the visible edge.
arch_height = 5; // mm
arch_width = 15; // mm
arch_top_height = 2; // mm
arch_side_width = 2.5; // mm
arch_leg_gap = 10; // mm
arch_corner_radius = 0.5; // mm

// Interior locating protrusions rising from the recessed tray floor.
protrusion_x_inset = 5; // mm
protrusion_radius = 0.8; // mm
protrusion_height = 1; // mm

// Rectangle sitting on y = 0 with only its two top corners rounded:
// the hull of the bottom edge and the two top corner circles.
module top_rounded_rect(width, height, r) {
  hull() {
    translate([-width / 2, 0])
      square([width, eps]);

    for (x_side = [-1, 1])
      translate([x_side * ((width / 2) - r), height - r])
        circle(r = r);
  }
}

module arch_profile() {
  difference() {
    top_rounded_rect(arch_width, arch_height, arch_corner_radius);

    // Open space between the two arch legs.
    translate([-arch_leg_gap / 2, -eps])
      square([arch_leg_gap, arch_height - arch_top_height + eps]);
  }
}

// Shallow base tray: a 2 mm outer plate with a 1 mm-deep recessed center.
module base_tray() {
  difference() {
    translate([0, 0, outer_height / 2])
      cube([outer_length, outer_width, outer_height], center = true);

    translate([0, 0, outer_height - (inner_depth / 2) + eps])
      cube([inner_length, inner_width, inner_depth + (2 * eps)], center = true);
  }
}

// X center of the end lip (and arch) on the given short side.
function end_lip_x(x_side) = x_side * ((outer_length / 2) - (side_piece_depth / 2));

// Raised lip on each short end of the tray. The arches sit on these lips.
module end_piece(x_side) {
  translate([
    end_lip_x(x_side),
    0,
    outer_height + (side_piece_height / 2)
  ])
    cube([side_piece_depth, outer_width, side_piece_height], center = true);
}

// One continuous end arch, extruded through the 1 mm end lip depth.
// The profile is drawn in the xy plane, then stood upright and turned to face
// along x so it spans the lip thickness.
module arch(x_side) {
  arch_z_base = outer_height + side_piece_height;
  arch_depth = side_piece_depth;

  translate([end_lip_x(x_side), 0, arch_z_base])
    rotate([90, 0, 90])
      linear_extrude(height = arch_depth, center = true)
        arch_profile();
}

// Small upward posts centered in the tray width and inset from each short side.
module protrusion(x_side) {
  translate([
    x_side * ((outer_length / 2) - protrusion_x_inset),
    0,
    outer_height - inner_depth
  ])
    cylinder(h = protrusion_height, r = protrusion_radius);
}

base_tray();

for (x_side = [-1, 1]) {
  end_piece(x_side);
  arch(x_side);
  protrusion(x_side);
}
