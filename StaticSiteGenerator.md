

# Finding the Static Site Generators

"Hi, thank you for coming to this interview. As this is the second round for a very senior position, we are going to ask a more difficult question, my apologies. Could you write a static site generator?"

"I'm not sure I entirely follow- what is the site about?"

"It's ok, these interviews are always disorienting. Umm, I don't see how it matters, but lets say childrens toys"

"Oh, you want me to compute the static site's generators! Thank you for clarifying, yes, that's one of my favorite optimizations!"

"We may be talking past each other- I mean something like jekyll or- "

"Well everyone knows the generator of jekyll and hyde is just hyde, but that's trivia, not an interview question. Ok, we'll start with the slow but simple solution, then optimize."

My fingers lightly tap over the keyboard, stumbling a bit on the @ signs- my current position uses very little linear algebra but I'm delighted to pick it back up if that's where folks are hiring.


```
d = lambda D, z: sum((d(D, z+[i]) for i in range(len(D)) if np.allclose(
        D[z+[i]]@D[i],
        D[:len(z)+1]@D[len(z)])),
    []) if len(z)!=len(D)else[np.eye(len(D))[z]]
```
"Ah- Let me interrupt you for a moment- We want you to program in a language you are comfortable, and so have an open language policy for interviews, but it would help if you picked a language
I'm familiar with. Could we do this interview in Go, C++, Python, or Java?"

I really need this job, so instead of correcting him, I correct myself.

```
def find_rigid_permutations(D, z=[]): 
    return sum((find_rigid_permutations(D, z+[i]) for i in range(len(D)) if np.allclose(                                                                                                                                                                    
        D[z+[i]]@D[i],                                                                                                                                                                                                                      
        D[:len(z)+1]@D[len(z)])),                                                                                                                                                                                                           
    []) if len(z)!=len(D)else[np.eye(len(D))[z]]  

```
"Sorry about that. Is that better?"

He nods his head yes, but his body language says no. Nonetheless, the only way forward is through.

"One of my favorite toys is the rubiks cube, so that's what we'll be generating today. First we plop the stickers where they go"


```
sticker_coords = np.array([s for s in itertools.product(range(-2,3), repeat=3) 
                           if (np.abs(s)==2).sum()==1])
colors = .5 + .5 * np.round(sticker_coords / 2)
stickers_in_slice = np.sum(sticker_coords[:, 0] < 0)
```
"And then check how they spin!"

```
global_perms = find_rigid_permutations(sticker_coords)

slice_perms = find_rigid_permutations(sticker_coords[:stickers_in_slice])
move = np.eye(len(sticker_coords))
move[:stickers_in_slice, :stickers_in_slice] = move[slice_perms[3]]
```

The interviewer glances at his phone again. I suspect he is offended by the magic number 3, and make a mental note to do better next time.

I attempt to pull his attention back to my qualifications with some inline Javascript.


```
global_perms = rigid_perms(sticker_coords)

slice_perms = rigid_perms(sticker_coords[:21])
move = np.eye(len(sticker_coords))
move[:21, :21] = slice_perms[3]

view = np.linalg.qr(np.random.randn(3, 3))[0]

with open("output.html", "w") as static_site:
    static_site.write(
        f"""
    <!DOCTYPE html><html><body><script>

    let mul = (A, B) => A.map((row, i) => B[0].map((_, j) =>
        row.reduce((acc, _, n) => acc + A[i][n] * B[n][j], 0)))

    var state = {np2js(np.eye(len(sticker_coords)))}
    const coords = {np2js(sticker_coords @ view * 14 + 35)}
    var moves = [state]
    document.addEventListener("keypress", (event) => {{
    """
    )
    for i, generator in enumerate([move, global_perms[15], global_perms[9]]):
        static_site.write(
            f"""
        if (event.key == {i}) {{
            moves = (new Array(10).fill( {np2js(expm(.1 * logm(generator)))})).concat( moves);
        }}
        """
        )
    static_site.write(
        """
    });
    setInterval(step, 20);
    function step() {
        if (!moves.length) return;
        state = mul(state, moves.pop());
        const locations = mul(state, coords);
        document.body.innerHTML= `
    """
    )
    for i, color in enumerate(sticker_colors):
        static_site.write(
            f"""
            <div style='
                position: absolute; 
                left: ${{locations[{i}][1]}}px; 
                top: ${{locations[{i}][2]}}px; 
                z-index: ${{Math.round(locations[{i}][0])}}; 
                color: rgb({color[0]} {color[1]} {color[2]});
            '>
                &#x2B24;
            </div>
        """
        )
    static_site.write("`;}</script></body></html>")
```

