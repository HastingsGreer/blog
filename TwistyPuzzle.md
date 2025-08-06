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
    display_matrix.append([j, -i])
display_matrix = np.array(display_matrix) - np.mean(display_matrix, axis=0)
def show(state):
  [plt.text(x, y, str(i), ha='center', va='center', fontsize=16)
   for i, (x, y) in enumerate(state @ display_matrix / 5 + .5)]
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

Now, writing out that matrix A sucked, and it's only going to get worse to do manually as we scale up the sticker count: Instead, lets let a computer find it!

The plan is to create a general function that takes a set of points (such as the one in our display matrix) and returns all the possible rotations of the the points that correspond to permutations of the points, simply by finding all solutions to 

$$ AD = DQ $$

where $D$ is the display matrix we computed earlier, $A$ is a permutation, and $Q$ is a physical rotation. 

This can be done efficiently by a backtracking solve. Let $P$ be a prefix matrix, like 

$$ P = 
\begin{pmatrix}
1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 1 & 0 & 0 & 0 & 0 & 0  & ...\\
0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 & 0 & 0
\end{pmatrix}
$$

Think of this as $PA$ takes the first 5 rows of $A$

Then, if $AD = DQ$, we know that $PAD = PDQ$

This lets us use a standard recursive iterator through all permutations, but with pruning whenever PAD = PDQ is unsolvable.


```!
py""" #hide
def AD_DQ_solve(D):

    def feasible(prefix):
        PA = np.eye(len(D))[prefix]
        P = np.eye(len(D))[: len(prefix)]
        Q, residuals, _rank, _singular_values = np.linalg.lstsq(P@D, PA@D)

        if np.abs(np.linalg.det(Q) + 1) < .001:
            return False

        if len(prefix) == len(D):
            permutations.append(PA)
            rotations.append(Q)
            return False

        return len(residuals) == 0 or (np.max(np.abs(residuals)) < 0.0001).item()

    def recursive_permutations(prefix):
        for i in range(len(D)):
            if not i in prefix:
                continuation = prefix + [i]
                if feasible(continuation):
                    recursive_permutations(continuation)

    permutations = []
    rotations = []
    recursive_permutations([])
    return permutations, rotations
global_perms, global_rotations = AD_DQ_solve(display_matrix)
[print(np.argmax(perm, axis=0)) for perm in global_perms]
""" #hide
print(String(take!(buf))) #hide
```

This `global_perms` array is super useful, because 






