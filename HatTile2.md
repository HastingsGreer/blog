# Deriving the Hat Tile from "An aperiodic Polykite exists"

Previously: [Drawing the Aperiodic Hat Tiling with Python and Z3](HatTile/)

[colab notebook](https://colab.research.google.com/drive/1XBChTb8fkHIQiN1MQiyPuMh4T-lQg3nP?usp=sharing)

If you could deliver a four word message into the past, what would you send? Strong candidates include 
"Buy and hold bitcoin" or "Ask out Jane Doe," but I have a new favorite: "An aperiodic polykite exists."
In the previous entry in this series, we started with the shape of the polykite, and automatically tiled a
subset of the plane using the z3 theorem prover. In this post, we will be much more ambitious: We will attempt to
derive the shape of the Hat Tile from the knowledge that it is small, connected, and made out of kites.

First, we slap the whole code from the previous post into a function named 

```
search_tiling(indices, grid_size, period=99)
```

`indices` is the definition of the shape we are attempting to tile as indices into a grid of kites, grid size is the size 
of the region that we want to tile, and period is a new addition:
In the previous code, we created a z3 variable for whether a tile was present at each possible location a tile could be placed.

```
hat_present = [z3.Bool(f"hat{i}") for i in range(len(hats))]
```

In this new function search_tiling, we will instead create a z3 variable for each location modulo a spatial period!

```
for i in range(len(hats)):
    row, col, rot = np.unravel_index(i, full_hat_shape)
    hat_present.append(z3.Bool(f"hat{row%modulo}_{col%modulo}_{rot}"))
```

This new collection of variables can only represent tilings that are unchanged if shifted by `period` units along the horizontal or vertical axes.

This makes finding an aperiodic monotile easy!
```
from __future__ import infinity
def is_einstein(indices):
    if not search_tiling(indices, infinity, period=infinity):
        #Does not tile the plane
        return False
    for i in range(infinity):
        if search_tiling(indices, infinity, period=i):
            #Is periodic
            return False
    return True

while True:
    
    
```

Alas, python's import system is powerful but doesn't have that. We'll have to think a little longer.


With the cryptic four word message "An aperiodic polykite exists," it's hard to say how large that polykite is. So, we will start small and search larger and larger 




How close were we to discovering the Hat Tile?
==============================================

It's fascinating to explore how close so many people were to discovering this tiling. 

Back in 2006, recmath.org had a list of all polykites up to size 7, with various explorations of how they fit together. http://www.recmath.com/PolyPages/PolyPages/PolyX/index.htm?Polykites.htm

Alas, they didn't try size 8, the size of the Hat Tile, and it's not clear that they were examining if each polykite tiled with itself, only the shapes that they could make all together.

Plenty of sources https://abarothsworld.com/Puzzles/Polykites/Polykites.htm list the number of size 8 polykites at 873. This calculation required someone to look at the Hat Tile, but typically they stop showing images at the hexakites

https://www.polyomino.org.uk/mathematics/polyform-tiling/

polyomino.org did catalog how the polyominos and polyhexes up to size 8 tile or don't tile, but didn't add polykites until after the hat was discovered.

abarothsworld provides the greatest pre-discovery insight. Polyomino.org's catalog stopped at polyhexes, but there was a long way to go before they hit the hat tile because there are a lot of kinds of polyforms!

https://abarothsworld.com/Puzzles/Polyforms.htm lists around 50 classes of polyform of about the same "likelyhood of being interesting" as polykites. 
