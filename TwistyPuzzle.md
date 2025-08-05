Rubiks cubes are fascinating, and I've been working on writing a post about solving them for a while. At first, I thought that the post would be about solving them, and 
the draft of that post is at (link) but I quickly realized that the post about solving them needed playable, embedded widgets where the reader could try the techniques in question. 

Thus, this post started, a prequel of sorts, about how to embed a twisty cube widget in a website. It becomes a bit of a journey.

I started off implementing a copy of Simon Tatham's "Twiddle", which is a simplified puzzle with rubiks like motion. Instead of stickers on cublets, it just has 16 tiles in a square, with
the ability to turn 3x3 sub-sets of the puzzle by 90 degrees. I elected to represent the state of the puzzle and the moves as 16 x 16 permutation matrices. Then, I could apply a move 
by simply multiplying it with the state, and render the puzzle by multiplying the state with a "piece location" matrix. 


