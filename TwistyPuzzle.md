\fig{header}

The in browser, playable rubiks cubes, including a pyraminx and a face turing octahedron, are currently hosted [here](http://cubes.hgreer.com). Hopefully this post will eventually get to explaining how they work



Rubiks cubes are fascinating, and I've been working on writing a post about solving them for a while. At first, I thought that the post would be about solving them, and 
the draft of that post is at (link) but I quickly realized that the post about solving them needed playable, embedded widgets where the reader could try the techniques in question. 
```!
#hideall
using PyCall #hide
buf = IOBuffer(); #hide
pyimport("sys").stdout = buf; #hide
pyimport("sys").output = @OUTPUT
print(String(take!(buf))) #hide
pyimport_conda("scipy", "scipy") #hide
```

[The unfinishable post in question](SolveARubiksCubeWithoutMemorization.md)

Thus, this post started, a prequel of sorts, about how to embed a twisty cube widget in a website. It becomes a bit of a journey.

I started off implementing a copy of Simon Tatham's "Twiddle", which is a simplified puzzle with rubiks like motion. Instead of stickers on cublets, it just has 16 tiles in a square, with
the ability to turn 3x3 sub-sets of the puzzle by 90 degrees. I elected to represent the state of the puzzle and the moves as 16 x 16 permutation matrices. Then, I could apply a move 
by simply multiplying it with the state. Render the puzzle by multiplying the state with a "piece location" matrix. 



```!
py""" #hide
import numpy as np
import matplotlib.pyplot as plt
import sys
state = np.eye(16)
display_matrix = []
for i in range(4):
  for j in range(4):
    display_matrix.append([j / 4 + 1/8, 7/8 - i / 4])
display_matrix = np.array(display_matrix)
def show(state):
  [plt.text(x, y, str(i), ha='center', va='center', fontsize=16)
   for i, (x, y) in enumerate(state @ display_matrix)]
show(state)
plt.savefig(sys.output + "/board.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
```
\fig{board}

Now, for a first pass, we just hand write the permutation for a single move


```!
py""" #hide
A = (np.
array([[0., 0., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 0., 0., 0., 0., 0.],
       [0., 0., 0., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 1., 0., 0., 0., 0., 0., 0., 0., 0.],
       [1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 1., 0., 0., 0., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 0., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 0., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 0., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 0.],
       [0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1.]]))
show(A @ state)
plt.savefig(sys.output + "/boardTwisted.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
```
\fig{boardTwisted}

This successfully twisted the top left square! 

Now, this is where the magic starts, and the justification arrives for representing moves via matrices. How are 
we going to animate this move? Easy! if we want the move to take 2 frames, we just take the square root of A! 
```!
py""" #hide
from scipy.linalg import logm, expm
show(expm(logm(A) / 2) @ state)
plt.savefig(sys.output + "/boardroot.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
```
\fig{boardroot}

This works for any fraction of a turn we want, allowing easy smooth animation of any permutation.

