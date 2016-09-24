This project is meant to explain some of the graphical effects used in the PuzzleBloom game available at puzzlebloom.com

You may use this software for any purpose you'd like, although if you make one of the effects a highlight of your project, some form of attribution or a link to robert.cupisz.eu would be a nice touch.

- Robert Cupisz, The PuzzleBloom Team




FertileGround

The 'fertile ground' or transition effect is a composition of several effects. In this project you can find some of them:

FertileGround shader - the basic idea is that each pixel needs to know, if it's inside or outside of the affected radius. If it's inside - it uses the colour from the greenland texture; else - wasteland texture. There is a smooth blending of the colour at the border (linear atm, but you can uncomment the sigmoidal falloff version). Additionally shape of the border is affected by two kinds of noise: low frequency, to give it a wavy shape (and a 'creeping out' behaviour) and high frequency, to place those nice small spots around it.

FertileGround script - computes and passes all necessary uniform variables to the shader. Thanks to the script you can move, rotate around y axis and scale non-uniformly all the objects affected by the transition and the border will always be consistent. Since the FertileGround shader is quite computationally complex, for better performance it is being used only during the transition. Before and after it is being swapped with a simple shader with only one texture.

Grass - in our case grass looked best if it was growing in small, dense areas (or 'patches') of proper shape. Instead of placing all the grass quads manually or painting them like in Unity's terrain engine, I asked one of our artists to define shape of the grass patches by modelling simple geometry. Based on that shape, grass quads are being generated and placed automatically; they are rotated randomly and are smaller by the edges, to give the patches a more natural look. Density of the grass can be regulated to balance quality against performance. The grass shader makes it fade in along with the ground transition.

Ring particles - these are being emitted from a ring-shaped mesh. You could do a vertical ray cast from each of the mesh vertices and move those to fit the shape of the ground, to make the particles follow it nicely.

As you might have guessed, we were heavily inspired by the latest Prince of Persia ;)
 


 

EdgeDetection

PuzzleBloom uses an improved version of the edge detection filter from the 'Shader Replacement' example project found at the unity website.

The original edge detection filter claims to be detecting discontinuities both in direction of the normals and in depth. The problem is that depth is stored as alpha channel in a render texture, which doesn't give it enough precision, especially if the far clip plane is set at a very big distance, as it is in the demo.

As a result the entire scene receives the exact same depth value, no discontinuities are detected and no edges appear e.g. at the top of the spheres or cubes (when viewed slightly from above), as these parts of the surface have the same direction of normals as the background they're being drawn on.

To fix this problem, I've decreased far clip plane distance and added a small modification to the filter itself, to make it as sensitive for small as for large distances.

(Another possibility would be of course to render depth to a separate render texture and use all four channels to encode it)

As a bonus, there is a possibility of disabling the outline for some objects (in PuzzleBloom we wanted no outline on the avatar, for instance). This is achieved by using a degenerated replacement shader for objects with tag 'NoOutline' and then detecting that case in the filter.