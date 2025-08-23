In the previous section of this post, we developed a rubiks cube widget using some pretty generic tools. The next step is to move beyond the cube, to the full spread of platonic solids.

To do this, instead of representing a sticker as a point, we represent it as a polygon. The data structure for this is two part, a list of points (like before) and then a list of polygons, with the points
represented as indexes into the point list. 
We start with representing a solid as one polygon per face, and then iteratively cut all the polygons to create each turning part.

The permutation solver we developed can be run against the list of points as before, it doesn't need to know about the polygon structures built on those points.
