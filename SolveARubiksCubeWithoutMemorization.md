You've probably seen tutorials on how to solve a rubiks cube- but did they seem deeply unsatisfying? They introduce long sequences of moves that must be memorized, without explaining how they were created. If you want to solve a Rubiks cube again years later, if you have forgotten a single step of one of these sequences, you are up a creek without a paddle unless you have internet access to learn again.

No longer! Once you have followed this tutorial, you will permanently be able to solve a rubiks cube.
Your future solves may take a few hours and and require pencil and paper, but they will not require internet access. This is a tutorial about inventing sequences, not memorizing them. Thus, whenever we show specific move sequences,
they will solve a different, freely available online puzzle- if you want cubey victory, you will then have to work out analogous cubey sequences. 

But first, an aside. If you have read other guides on rubiks cubes, you may have three sticky ideas in your head: one good and two bad. The good idea is that we don't need to solve stickers- we need to solve pieces. Each sticker is attached to a piece, and a sticker that is on the right colored side does you no good if other stickers on the same piece are on the wrong colored sides. Now, the bad ideas: someone may have taught you that "the centers never move." Nonsense- hold the top and bottom layers
fixed, and turn the middle layer! Look- the centers moved. This sort of turn is important to _easily_ solving the cube. It's a different way of looking at the same problem, but the difference is important.
Second, you probably were taught to solve the cube layer by layer. This is one of the _fastest_ ways to solve a cube, but it is not the easiest to invent: it is much easier to solve corners, then edges, and then centers.
These are linked: once you see that moving the middle slice is valid, it becomes clear that moving any middle slice doesn't affect the corners. Thus, once you have solved the corners, you can freely experiment with 3 distinct middle slice moves without disturbing the corners.
This is much more freedom than the layer by layer approach, where after solving a layer, you only have a single safe move remaining.

This is the last time we will mention a cube- remember, solve corners then centers then edges. 

Simon Tatham's "Twiddle"

https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/twiddle.html#4x4n3

animation of random piece moves

Two classes of piece- no move ever wil put 1 in the slot where 2 belongs. We will solve 1 class, then the other.

First piece class

Technique A. Go as far as you can intuitively, leaving yourself freedom

Solving the piece 1 is easy- just move it to the top left corner. 

Solving the piece 3 is easy- just move it to the top center right

Solving 6 would be easy, but now we have no free moves left. Instead, lets solve 9. This leaves 5 pieces unsolved, and we can rotate them all freely. However, with only one free rotation
left, we can no longer make changes to the puzzle without disturbing our solved pieces

technique B: take it out, then put it back

We first write down the locations of our unsolved pieces.

6 11
16 
14 8

We then take out the 3, and then put it back using a different sequence of moves. (Depending on available working memory, it's probably best to write this sequence down). we denote the 4 possible moves

ab
cd

and perform 

bdddb

The unsolved pieces are now 

11 6
14
8 16

lets rotate this to resemble the original locations, making our sequence

bdddbd

6 16
14 
11 8

and what we have found is a sequence that (restricted to the first class of pieces) cycles a diagonal of three pieces: 3 cycles are deeply useful sequences. By alternating rotating the bottom square and peforming this sequence to permute along the diagonal, it is easy to solve the remaining pieces of the first class. This introduces _parity_: you may find yourself in a situation where it appears that you need to swap 2 pieces, which is impossible to achieve with any sequence of 3 piece cycles. However, this is an illusion, as _rotating the bottom square once_ performs a 4 piece permutation, which can be combined with a 3 piece cycle to create a 2 piece cycle (hint hint)

animation of solving first class.

Now, on to the second class of piece.

Technique C: moves that commute with respect to a class

Check it out- any sequence of top left and bottom right moves where the total number of top left and bottom right moves both add to 4, don't affect any of the first class of piece.

This is because the top left move only affects 1 3 9 11, and the bottom right only affects 6 8 14 16. Therefore, as far as the first class pieces are concerned, these moves commute: you can swap two moves in the sequence without affecting the outcome. This gives us a rich collection of sequences to experiment with, analogous to the collection of possible "Take it out and put it back" sequences from Technique B. Because these sequences are guaranteed to not move the first class pieces, they are also cheap to experiment with after solving the first class- we won't lose our work. //(I cannot resist another hint: once you have solved corners on the rubiks cube, any middle slice move commutes with a side move with respect to the corners)

As a standard step in investigating a sequence, we will write down the locations of all the second class pieces before and after performing it. 

First, we try AADDAADD

cycles like 2 triangles- not that useful

ADDDAADD

a 5 cycle, not that useful

adadadad

5 cycle

adddaaad

Ah- two 2-cycles. This is usable to solve most of the class 2 pieces


















Technique D: size of orbits, permutations, and repeated sequences


Basically, any short sequence of moves will, after being repeated enough times, restore the puzzle to its initial state. However, the way that it does so can be very useful. Specifically, any sequence of moves will execute a number of cycles in the locations of the pieces of the puzzle. If you execute the sequence a number of times that is divisible by the length of a cycle, those pieces won't move. If the cycles are different lengths, then you can isolate one cycle by performing the sequence the length of another cycle.

The cycles in location space are often different lengths than the cycles in orientation space

Any sequence of moves on a rubiks cube will permute the edges, 

Twiddle: 
ACC x 6 ACCC x 4 rotates two pieces




Basically, the purpose of an ordinary rubiks cube





