You've probably seen tutorials on how to solve a rubiks cube- but did they seem deeply unsatisfying? They introduce long sequences of moves that must be memorized, without explaining how they were created, and if you want to solve a Rubiks cube again years later, if you have forgotten a single step of one of these sequences, you are up a creek without a paddle unless you have internet access to learn again.

No longer! Once you have followed this tutorial, you will permanently be able to solve a rubiks cube.
Your solves may be long and require pencil and paper, but they will not require internet access. The trick is, this is a tutorial about inventing algorithms, not memorizing them: whenever we show specific moves,
they will solve a different puzzle than the Rubiks cube- if you want cubey victory, you will then have to work out analogous sequences on the cube. 

#Fundamentally, this blog post is about "How do I construct a sequence of moves which only affects a few pieces on a rubik's cube?

First of all, if you have read other guides on rubiks cubes, you may have two sticky ideas in your head: First, someone may have taught you that "the centers never move." Nonsense- hold the top and bottom layers
fixed, and turn the middle layer! Look- the centers moved. This sort of turn is important to easily solving the cube. It's a different way of looking at the same problem, but the difference is important.
Second, you probably were taught to solve the cube layer by layer. This is one of the _fastest_ ways to solve a cube, but it is not the easiest to invent: it is much easier to solve corners, then edges, and then centers.
These are linked: once you see that moving the middle slice is valid, it becomes clear that any middle slice doesn't affect the corners. Thus, once you have solved the corners, you can freely experiment with 3 middle slice moves without disturbing them.
This is much more freedom than the layer by layer approach, where after solving a layer, you only have a single safe move remaining.

This is the last time we will mention a cube- remember, solve corners then edges then centers. 

Simon Tatham's "Twiddle"

https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/twiddle.html#4x4n3

$animation of random piece moves

Two classes of piece. We will solve 1 class, then the other.

First class

Technique A. Go as far as you can intuitively, leaving yourself freedom

Solving the piece 1 is easy- just move it to the top left corner. 

Solving the piece 3 is easy- just move it to the top center right

Solving 6 is easy, but now we have no free moves left. Instead, lets solve 9. This leaves 5 pieces unsolved, and we can rotate them all freely. However, with only one free rotation
left, we can no longer make changes to the puzzle without disturbing our solved pieces

technique B: take it out, then put it back

We first write down the locations of our unsolved pieces.

6 11
16 
14 8

We then take out the 3, and then put it back using a different sequence of moves.

The unsolved pieces are now 

11 6
14
8 16

lets rotate this to resemble the original locations

6 16
14 
11 8

and what we have found is a sequence that (restricted to this class of pieces) permutes three pieces. Our first algorithm! 











Trick 1: size of orbits, permutations, and repeated sequences

Any sequence of moves on a rubiks cube will permute the edges, 




Basically, the purpose of an ordinary rubiks cube





