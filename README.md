this demo showcases my method:

+(CGMutablePathRef) newClosedPathWithWidth: (float) pw fromPath:(CGPathRef) path;

The function creates the outline of a path.

It accepts a CGpath (closed or open) and outputs a CGpath  that surrounds the given one. You can specify the width of the outline created.

The mehtod uses Accelerate Framework for faster calculations.

I use it in Soundbeam app : http://www.evilwindowdog.com/soundbeam

***

In this demo 3 paths are used as inputs and 3 outline paths are created

Core Animation is used to animate custom propertis: the width of the outline and the angle of the rotation of one of the input paths.

The 3 input paths and the 2 outline paths produced are rendered using core graphics. The third outline is used as the shadowpath of a CAlayer.

Video running the demo: http://www.youtube.com/watch?v=oUh6EtC_wnY

My blog's post: http://www.wiggler.gr/2011/09/12/function-to-create-a-paths-outline/

The way the outline is calculated: http://stackoverflow.com/questions/5641769/how-to-draw-an-outline-around-any-line/7394129#7394129


***

PS. I've also added a functon that uses apple's implementation for getting the oultine path:

+(CGPathRef) newPathFromStrokedPathWithWidth: (float) pw fromPath:(CGPathRef) path;

you can enable it in the demo by setting  "#define apple_implementation 1" at "customrender.m"
