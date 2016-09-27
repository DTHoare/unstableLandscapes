# unstableLandscapes
Terrain generation in Processing 3

The code uses the diamond-square algorithm to generate landscapes.
Waves are created with perlin-noise amplified sinusoidal waves.

The terrain is shown as an isometric block of land, with directional lighting.

Also includes a class for 2D terrain generation, initially used a proof of concept.

-------------------------------------------------------
CONTROLS:

All modes:

  * LEFT/RIGHT arrows : rotate terrain by 90 degrees
  * m : 'Mode' changes between high resolution and low resolution  
  * p : 'Print' saves the next 30 frames

Camera modes:

  * WASD : Move forwards/left/down/right across x-y plane

Flying Camera Mode:

  * SHIFT/CONTROL : Move up and down the z axis

-------------------------------------------------------
FUTURE UPDATES:

* Add keyboard switch between first person and ortho mode
* Look into performance speed increase
* Work on waterfall system for ortho mode
