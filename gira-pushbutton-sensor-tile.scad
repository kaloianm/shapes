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

///////////////////////////////////////////////////////////////////////////////////////////////////
// Configuration Block

// Outer envelope of the tile:
// The flat face at z = 0 is the visible side.
length = 55.5; // mm
width = 18.5; // mm
thickness = 2; // mm

// Cosmetics of the visible face:
// Rounded plan-view corners and a 45-degree chamfer around the face edge for improved aesthetic.
// Also hides the elephant's foot of the first layer. Set either to 0 for a plain (square) box.
// The chamfer must be well above the first-layer squish (~0.2-0.3 mm) or it gets filled in.
corner_radius = 1; // mm
face_chamfer = 1; // mm

// Shell:
// The tray cavity is whatever is left inside the perimeter wall above the floor.
wall_thickness = 1; // mm
floor_thickness = 1.5; // mm (the original tile is 1 mm; 1.5 mm is noticeably stiffer)

// Raised lip across each short end, on top of the rim, that the clip stands on.
lip_height = 0.5; // mm

// Retaining arch clip on each short end:
// Two legs and a top bar. Only the two outer top corners are rounded. The clip is flush with the
// outer end face and grows inward only; the lip under it and the end of the tray cavity are filled
// to the same thickness so the clip is fully supported down to the floor.
clip_thickness = 1.5; // mm (the original tile is 1 mm; 1.5 mm makes the legs stronger when printed using PLA and still fits the slot)
clip_width = 15; // mm
clip_height = 5; // mm
clip_bar_height = 2; // mm
clip_gap = 8; // mm, between the legs
clip_corner_radius = 0.5; // mm
// 45-degree chamfers in the two top corners of the opening. They shorten the unsupported bridge under
// the bar (clip_gap - 2 * this) so it sags less when printed. Set to 0 for a square opening.
clip_gap_chamfer = 1; // mm

// Small pins:
// Rising from the tray floor to slightly above the rim, centered across the width and inset from each end.
pin_inset = 7; // mm
pin_radius = 0.5; // mm
pin_protrusion = 0.2; // mm, above the rim

// Configuration Block
///////////////////////////////////////////////////////////////////////////////////////////////////

cavity_length = length - 2 * wall_thickness;
cavity_width = width - 2 * wall_thickness;
cavity_depth = thickness - floor_thickness;

// Plan-view outline of the tile, optionally inset from the outer edge (corners stay concentric).
module footprint_2d(inset = 0) {
  offset(r = corner_radius - inset)
    square([length - 2 * corner_radius, width - 2 * corner_radius], center = true);
}

// Solid plate with the face edge chamfered: the hull of the full footprint (from the chamfer height
// up) and the footprint inset by the chamfer at the face.
module plate() {
  hull() {
    linear_extrude(eps)
      footprint_2d(face_chamfer);

    translate([0, 0, face_chamfer])
      linear_extrude(thickness - face_chamfer)
        footprint_2d();
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

// 2D arch profile of one clip (y up from the lip); extruded into 3D by end_clip().
module clip_profile_2d() {
  difference() {
    // Rectangle with its two top corners rounded.
    hull() {
      translate([-clip_width / 2, 0])
        square([clip_width, clip_height - clip_corner_radius]);

      for (side = [-1, 1])
        translate([side * (clip_width / 2 - clip_corner_radius), clip_height - clip_corner_radius])
          circle(clip_corner_radius);
    }

    // Opening between the legs, with its top corners chamfered.
    opening_top = clip_height - clip_bar_height;
    polygon([
      [-clip_gap / 2, -1],
      [clip_gap / 2, -1],
      [clip_gap / 2, opening_top - clip_gap_chamfer],
      [clip_gap / 2 - clip_gap_chamfer, opening_top],
      [-clip_gap / 2 + clip_gap_chamfer, opening_top],
      [-clip_gap / 2, opening_top - clip_gap_chamfer],
    ]);
  }
}

// Builds the raised lip and the arch clip on one short end of the tile. Pass x_side = -1 for the
// left end or 1 for the right end.
module end_clip(x_side) {
  base_height = cavity_depth + lip_height;

  intersection() {
    // Trims the full-width base to the rounded corners of the footprint.
    linear_extrude(thickness + lip_height + clip_height)
      footprint_2d();

    // Flush with the outer end face, extruded clip_thickness inward.
    translate([x_side * (length - clip_thickness) / 2, 0, floor_thickness])
      rotate([90, 0, 90])
        linear_extrude(clip_thickness, center = true) {
          // Base starts at the tray floor, so it is both the lip and the cavity fill under a clip
          // that is thicker than the wall.
          translate([-width / 2, 0])
            square([width, base_height]);

          translate([0, base_height - eps])
            clip_profile_2d();
        }
  }
}

module pin(x_side) {
  translate([x_side * (length / 2 - pin_inset), 0, floor_thickness])
    cylinder(h = cavity_depth + pin_protrusion, r = pin_radius);
}

tray();

for (x_side = [-1, 1]) {
  end_clip(x_side);
  pin(x_side);
}
