This demo showcases my functions that can:  
 1. calculate the outline of a given path (open or closed)  
 2. create a smoothed version of a path using bezier curves  
 

The functions come in 3 flavours: 
 1. UIbezier methods  
 2. functions that accept a CGPath as input (read about the limitations below)  
 3. C functions that accept array of floats as input  

I have also added a helper funtion that can print a CGPath in the console (usefull for debugging).

To use the functions include the header file "CGutilities.h" and use the soruce files: "CGutilities.m", "CGutilitiesBezier.m"

These functions are used in Soundbeam app : http://www.evilwindowdog.com/soundbeam

***

In this demo 5 input paths are used. Some of them have their outline calculated and rendered in red color. Some are "smoothened" and then rendered.  
The user can alter the tension of the control points of the bezier curves.

Core Animation is used to animate custom propertis: the width of the outline and the angle of the rotation of one of the input paths.


Video running the demo: http://www.youtube.com/watch?v=iOHvIiryfaQ

Older video: http://www.youtube.com/watch?v=oUh6EtC_wnY

My blog's post: http://www.wiggler.gr/2011/09/12/function-to-create-a-paths-outline/

The way the outline is calculated: http://stackoverflow.com/questions/5641769/how-to-draw-an-outline-around-any-line/7394129#7394129

The math behind control points calculations: http://scaledinnovation.com/analytics/splines/aboutSplines.html

***
The functions have some limitations. So read CGutilities.h carefully
