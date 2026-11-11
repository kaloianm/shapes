// Replacement/customizable cover tile for a Gira Pushbutton Sensor.
//
// A shallow tray with a raised lip and a retaining arch clip on each short end, plus two small pins
// inside the tray. Intended to fit the Gira Pushbutton Sensor 3 Komfort family, including the 3-gang
// KNX variant documented by Gira as item no. 5133 00.
//
// Product reference: https://katalog.gira.de/en-INT/datenblatt/4010337086857
//
// Print with the flat face on the bed (clips pointing up); no supports are needed.

// Smooth edge rounding
$fn = 50;

// Small epsilon to avoid SCAD Z-fighting (explained at https://en.wikipedia.org/wiki/Z-fighting)
eps = 0.01;

// Outer envelope of the tile. The flat face at z = 0 is the visible side.
length = 55.5; // mm
width = 18.5; // mm
thickness = 2; // mm

// Shell. The tray cavity is whatever is left inside the perimeter wall above the floor.
wall_thickness = 1; // mm
floor_thickness = 1.5; // mm (the original tile has a 1 mm floor; 1.5 mm is noticeably stiffer)

// Cosmetics of the visible face: rounded plan-view corners and a 45-degree chamfer around the face
// edge. The chamfer also hides the elephant's foot of the first layer. Set either to 0 for a plain box.
corner_radius = 1; // mm
face_chamfer = 0.5; // mm

// Raised lip across each short end, on top of the rim, that the clip stands on.
lip_height = 0.5; // mm

// Retaining arch clip on each short end: two legs and a top bar. Only the two outer top corners are
// rounded. The clip is flush with the outer end face and grows inward when made thicker than the
// wall; the lip under it and the end of the tray cavity are filled to the same thickness so the clip
// is fully supported down to the floor.
clip_thickness = 2; // mm (the original was 1 mm, as thick as the wall, and the legs snapped off)
clip_width = 15; // mm
clip_height = 5; // mm
clip_bar_height = 2; // mm
clip_gap = 8; // mm, between the legs
clip_corner_radius = 0.5; // mm

// Small pins rising from the tray floor to the rim, centered across the width and inset from each end.
pin_inset = 6; // mm
pin_radius = 0.5; // mm

cavity_length = length - 2 * wall_thickness;
cavity_width = width - 2 * wall_thickness;
cavity_depth = thickness - floor_thickness;

// Plan-view outline of the tile, optionally inset from the outer edge (corners stay concentric).
module footprint(inset = 0) {
  offset(r = corner_radius - inset)
    square([length - 2 * corner_radius, width - 2 * corner_radius], center = true);
}

// Solid plate with the face edge chamfered: the hull of the full footprint (from the chamfer height
// up) and the footprint inset by the chamfer at the face.
module plate() {
  hull() {
    linear_extrude(eps)
      footprint(face_chamfer);

    translate([0, 0, face_chamfer])
      linear_extrude(thickness - face_chamfer)
        footprint();
  }
}

// Plate with the tray cavity cut out of the top.
module tray() {
  difference() {
    plate();

    translate([0, 0, floor_thickness])
      linear_extrude(thickness)
        square([cavity_length, cavity_width], center = true);
  }
}

// Arch profile of one clip, drawn with y pointing up from where it stands on the lip.
module clip_profile() {
  difference() {
    // Rectangle with its two top corners rounded.
    hull() {
      translate([-clip_width / 2, 0])
        square([clip_width, clip_height - clip_corner_radius]);

      for (side = [-1, 1])
        translate([side * (clip_width / 2 - clip_corner_radius), clip_height - clip_corner_radius])
          circle(clip_corner_radius);
    }

    // Opening between the legs.
    translate([-clip_gap / 2, -1])
      square([clip_gap, clip_height - clip_bar_height + 1]);
  }
}

// Lip and clip on one short end (x_side = -1 or 1), extruded clip_thickness inward from the outer end
// face. The block starts at the tray floor so that it also fills the cavity under a clip that is
// thicker than the wall. The intersection trims it to the rounded corners of the footprint.
module end_clip(x_side) {
  base_height = cavity_depth + lip_height;

  intersection() {
    linear_extrude(thickness + lip_height + clip_height)
      footprint();

    translate([x_side * (length - clip_thickness) / 2, 0, floor_thickness])
      rotate([90, 0, 90])
        linear_extrude(clip_thickness, center = true) {
          translate([-width / 2, 0])
            square([width, base_height]);

          translate([0, base_height - eps])
            clip_profile();
        }
  }
}

module pin(x_side) {
  translate([x_side * (length / 2 - pin_inset), 0, floor_thickness])
    cylinder(h = cavity_depth, r = pin_radius);
}

tray();

for (x_side = [-1, 1]) {
  end_clip(x_side);
  pin(x_side);
}
