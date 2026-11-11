Shapes for 3D printing (OpenSCAD)
=================================

This repository contains parametric shapes modeled in OpenSCAD, intended to be exported as STL files and printed on a 3D printer.

## Models

| | Model | File |
| --- | --- | --- |
| <img src="images/gira-pushbutton-sensor-tile.png" width="100"> | **Gira Pushbutton Sensor Tile**<br>Replacement cover tile for Gira Pushbutton Sensor 3 Komfort<br><br>*Print settings:*<br>• Filament: matte or warm white PLA, or ASA/ABS (closer match to Gira "pure white")<br>• Layer height: 0.12 mm<br>• Brim: mouse ear (prevents warped corners)<br>• Bed: 60 °C first layer, 55 °C after (easier removal)<br>• Fan: off for the first 3 layers (better adhesion)<br>• Wall loops: 3–4 (stronger clips) | [`gira-pushbutton-sensor-tile.scad`](gira-pushbutton-sensor-tile.scad) |
| <img src="images/shelly-switch.png" width="100"> | **Shelly Switch Adapter**<br>Adapter enclosure for fitting a Shelly Mini behind a wall switch | [`shelly-switch.scad`](shelly-switch.scad) |

## Usage

- Open any of the `.scad` files in OpenSCAD.
- Adjust parameters at the top of the file as needed.
- Press F6 (Render) to generate the final model.
- Export the model as an STL file and slice/print it with your preferred toolchain.
