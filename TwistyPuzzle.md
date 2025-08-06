\fig{header}

The in browser, playable rubiks cubes, including a pyraminx and a face turing octahedron, are currently hosted [here](http://cubes.hgreer.com). Hopefully this post will eventually get to explaining how they work



Rubiks cubes are fascinating, and I've been working on writing a post about solving them for a while. At first, I thought that the post would be about solving them, and 
the draft of that post is at (link) but I quickly realized that the post about solving them needed playable, embedded widgets where the reader could try the techniques in question. 
```!
#hideall
using PyCall 
buf = IOBuffer(); 
pyimport("sys").stdout = buf; 
pyimport("sys").output = @OUTPUT 
pyimport_conda("scipy", "scipy") 
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
display_matrix = np.array(display_matrix) - np.mean(display_matrix, axis=0, keepdims=True)
def show(state):
  [plt.text(x, y, str(i), ha='center', va='center', fontsize=16)
   for i, (x, y) in enumerate(state @ display_matrix / 5 + .5)]
show(state)
plt.savefig(sys.output + "/board.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
```
\fig{board}

For a start, we just hand write the permutation for a single move


```!
py""" #hide
move = (np.
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
show(move @ state)
plt.savefig(sys.output + "/boardTwisted.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
```
\fig{boardTwisted}

This successfully twisted the top left square! 

This is where the magic starts, and the justification arrives for representing moves via matrices. How are 
we going to animate this move? Easy! if we want the move to take 2 frames, we just take the square root of move! 
```!
py""" #hide
from scipy.linalg import logm, expm
show(expm(logm(move) / 2) @ state)
plt.savefig(sys.output + "/boardroot.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
```
\fig{boardroot}

This works for any fraction of a turn we want, allowing easy smooth animation of any permutation.

Now, writing out that matrix `move` sucked, and it's only going to get worse to do manually as we scale up the sticker count: Instead, lets let a computer find it!

The plan is to create a general function that takes a set of points (such as the one in our display matrix, or a subset corresponding to a move) and returns all the possible rotations of the the points that correspond to permutations of the points, by finding all solutions to 

$$ DQ = AD $$

where $D$ is the display matrix we computed earlier, $A$ is a permutation, and $Q$ is a physical rotation. 

This can be done efficiently by a backtracking solve. Let $P$ be a prefix matrix, like 

$$ P_5 = 
\begin{pmatrix}
1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 1 & 0 & 0 & 0 & 0 & 0  & ...\\
0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 & 0 & 0
\end{pmatrix}
$$

Think of this as $P_5A$ takes the first 5 rows of $A$

Then, if $DQ = AD$, we know that $PDQ = PAD$

By contrapositive, if there are no solutions Q to $PDQ = PAD$, there are no solutions to $DQ = AD$

This lets us use a standard recursive iterator through all permutations, but with pruning whenever $PDQ = PAD$ is unsolvable.


```!
py""" #hide
def DQ_AD_solve(D):
    eye = np.eye(len(D))

    def feasible(permutation_so_far):
        if ( np.abs(np.linalg.norm(D[len(permutation_so_far) - 1]) - np.linalg.norm(D[permutation_so_far[-1]])) > 0.001):
            return False
        P = eye[: len(permutation_so_far)]
        PA = eye[permutation_so_far]
        Q, residuals, _rank, _singular_values = np.linalg.lstsq(P@D, PA@D)

        if np.abs(np.linalg.det(Q) + 1) < .001:
            return False

        if len(permutation_so_far) == len(D):
            permutations.append(PA)
            rotations.append(Q)
            return False

        return len(residuals) == 0 or (np.max(np.abs(residuals)) < 0.0001).item()

    def recursive_permutations(permutation_so_far):
        for i in range(len(D)):
            if not i in permutation_so_far:
                continuation = permutation_so_far + [i]
                if feasible(continuation):
                    recursive_permutations(continuation)

    permutations = []
    rotations = []
    recursive_permutations([])
    return permutations, rotations
global_perms, global_rotations = DQ_AD_solve(display_matrix)
[print(np.argmax(perm, axis=0)) for perm in global_perms]
""" #hide
print(String(take!(buf))) #hide
```

This `global_perms` array is super useful, because it not only gives all the moves that rotate the whole puzzle, it also gives all the sub-moves of the puzzle by computing `A @ move @ A.T` for all the symmetries A found by `DQ_AD_solve`


```!
py""" #hide
frames = 64
for j in range(frames):
    for i, element in enumerate(global_perms):
        plt.subplot(2, 2, i + 1)
        show(expm(1/16 * j * logm(element @ move @ element.T)))
    plt.savefig(sys.output + f"/all_move{j}.png") #hide
    plt.clf() #hide
""" #hide
print(String(take!(buf))) #hide
```
```!
#hideall
py""" #hide
from PIL import Image #hide
def collect_gif(name):
    images = []
    for j in range(frames):
        img = Image.open(sys.output + f"/{name}{j}.png")
        images.append(img)
    # Save as animated GIF
    images[0].save(
        sys.output + f"/{name}_animation.gif",
        save_all=True,
        append_images=images[1:],
        duration=30,  # milliseconds per frame (adjust for speed)
        loop=0,        # 0 = infinite loop
        optimize=True  # reduces file size
    )
collect_gif("all_move")
""" #hide
print(String(take!(buf))) #hide
```
\fig{all_move_animation}

Notice that we were able to combine 3 moves (rotate the whole puzzle, turn a piece, then rotate the whole puzzle back) and our animation approach fuses this into a single rotation.


In addition, for future puzzles, we won't need to write out `move` by hand: instead, we will take a subset of the display matrix corresponding to that part we want to rotate, and appy `DQ_AD_solve` to that.


That's enough to implement Twiddle! There's an interactive version [here](http://cubes.hgreer.com/). For the interactive version, I swapped out the matplotlib display for pygame, and then threw it all into the browswer using Pyodide, which is a python interpreter (with scipy, pygame, and numpy!) compiled to web assembly.

Next, it's time to move to the third dimension! With the groundwork we've laid, it's super easy.

We build a display matrix for a 3x3 rubiks cube, and record the colors of the permutable pieces since rubiks cube uses colors, not numbers.

```!
py""" #hide
import itertools
colors = []
display_matrix = []
for sticker in itertools.product(* [range(5)] * 3):
    sticker = np.array(sticker)
    if np.sum(sticker == 0) + np.sum(sticker == 4) == 1:
        colors.append(.5 + .5 * (0 - (sticker == 0) + (sticker == 4)))
        display_matrix.append(sticker)

display_matrix = np.array(display_matrix) - np.mean(np.array(display_matrix), axis=0, keepdims=True)

state = np.eye(54)

def show(state, ax):
    locations = state @ display_matrix
    ax.scatter(locations[:, 0], locations[:, 1], locations[:, 2], c=colors, s=800, alpha=1)
fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
show(state, ax)
plt.savefig(sys.output + f"/rubiks.png") #hide
plt.clf() #hide
    
""" #hide
print(String(take!(buf))) #hide
```
\fig{rubiks}

I use the global permutations to rotate the cube along any of its axes

```!
py""" #hide
global_perms, global_rotations = DQ_AD_solve(display_matrix)

for j in range(frames):
    for i, element in enumerate([1, 2, 4, 6]):
        element = global_perms[element]
        ax = plt.subplot(2, 2, i + 1, projection="3d")
        ax.set_xlim(-2, 2)
        ax.set_ylim(-2, 2)
        ax.set_zlim(-2, 2)
        show(np.real(expm(1/16 * j * logm(element))), ax)
    plt.savefig(sys.output + f"/rubiks_rotate{j}.png") #hide
    plt.clf() #hide
collect_gif("rubiks_rotate")
""" #hide
print(String(take!(buf))) #hide
```

\fig{rubiks_rotate_animation}
```!
py""" #hide
try:
    slice_perms, slice_rotations = DQ_AD_solve(display_matrix[:21])
    move = np.eye(54)
    move[:21, :21] = slice_perms[1]

    for j in range(frames):
        for i, element in enumerate([1, 2, 4, 6]):
            element = global_perms[element]
            ax = plt.subplot(2, 2, i + 1, projection="3d")
            ax.set_xlim(-2, 2)
            ax.set_ylim(-2, 2)
            ax.set_zlim(-2, 2)
            show(np.real(expm(1/16 * j * logm(element @ move @ element.T))), ax)
        plt.savefig(sys.output + f"/rubiks_slice_rotate{j}.png") #hide
        plt.clf() #hide
    collect_gif("rubiks_slice_rotate")
except Exception as e:
    print(e)
""" #hide
print(String(take!(buf))) #hide
```
\fig{rubiks_slice_rotate_animation}

```!
py""" #hide
try:
    for j in range(4):
        for q in range(16):        
                element = global_perms[j + 3]
                ax = plt.subplot(1, 1, 1, projection="3d")
                ax.set_xlim(-2, 2)
                ax.set_ylim(-2, 2)
                ax.set_zlim(-2, 2)
                
                state = state @ expm(1/16 * logm(element @ move @ element.T))
                show(np.real(state), ax)
                plt.savefig(sys.output + f"/rubiks_sequence{j * 16 + q}.png") #hide
                plt.clf() #hide
    collect_gif("rubiks_sequence")
except Exception as e:
    print(e)
""" #hide
print(String(take!(buf))) #hide
```
\fig{rubiks_sequence_animation}
