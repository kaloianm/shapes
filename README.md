Shapes for 3D printing (OpenSCAD)
=================================

This repository contains parametric shapes modeled in OpenSCAD, intended to be exported as STL files and printed on a 3D printer.

## Models

| | Model | File |
| --- | --- | --- |
| <img src="images/gira-pushbutton-sensor-tile.png" width="100"> | **Gira Pushbutton Sensor Tile**<br>Replacement cover tile for Gira Pushbutton Sensor 3 Komfort | [`gira-pushbutton-sensor-tile.scad`](gira-pushbutton-sensor-tile.scad) |
| <img src="images/shelly-switch.png" width="100"> | **Shelly Switch Adapter**<br>Adapter enclosure for fitting a Shelly Mini behind a wall switch | [`shelly-switch.scad`](shelly-switch.scad) |

## Usage

- Open any of the `.scad` files in OpenSCAD.
- Adjust parameters at the top of the file as needed.
- Press F6 (Render) to generate the final model.
- Export the model as an STL file and slice/print it with your preferred toolchain.

## Printing notes

### Gira Pushbutton Sensor Tile

- Print with the flat face down on a smooth build plate; no supports are needed.
- Use 0.12 mm layers, 100% infill and a 0.5 mm wall line width, so the 1 mm walls and clips print as two clean perimeters.
- Matte or warm white filament matches Gira "pure white" better than plain glossy white PLA; ASA/ABS look closer still.
- `floor_thickness` defaults to 1.5 mm for stiffness. Set it back to 1 if the tile fouls the sensor.
