# Chalk-V-Plotter
This repository contains several preprocessing steps on gcode in Cartesian coordinates for preparation and drawing with plaster.

3- The GCODE generated from the previous step has many breaks due to the lack of resolution of the PNG file. These fractures are fixed with the help of a smoothing by MATLAB.

4- The presence of long paths in GCODE becomes a problem in some structures. Therefore, it is necessary to break the long movement into several shorter movements. This is done in the fourth step by MATLAB.

5- Using chalk for drawing is different from using a pen: chalk is consumed and its length becomes shorter. Therefore, it is necessary to include its consumption in GCODE. This step is done with the help of MATLAB.
