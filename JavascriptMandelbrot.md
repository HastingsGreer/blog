
@def title = "Javascript Mandelbrot"
@def hascode = true
@def rss = "My projects that render the Mandelbrot Set with various techniques"
@def rss_title = "Mandelbrot"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]

# The fastest Javascript Mandelbrot in the land

[\fig{S_shape.png}](https://hastingsgreer.github.io/mandeljs/?;re=-1.76908145622740503158437671055574159956782550694262781469802596201397106425666554420093748345592145250;im=0.003037787152539119673394881819412740681023744946458660316743819462018920571341488787781769620915429870;r=0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061363668309;iterations=30000)
```
re=-1.7690814562274050315843767105557415995678255069426278146980259620139710642566655442009374834559214525490298159;
im=0.00303778715253911967339488181941274068102374494645866031674381946201892057134148878778176962091542987845068523;
r=0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006136366831622158191
```



Before anything else, 
[get going, explore the Mandelbrot Set!](https://hastingsgreer.github.io/mandeljs)

In early 2023, there was a gap in online Mandelbrot Set explorers. People had written fast, GPU based Mandelbrot Set renderers such as [munrocket](https://deep-mandelbrot.js.org/), but they only let you click a few times before you reached the bottom and ran into pixels. The
reason is that WebGL only has 32 bit floats, and this is just not very much precision for Mandelbrot zooming. This hurts twice: First, if you naively compute $z_{n + 1} = z_n$ in a shader, the limited bits in the mantissa (that is, the "a" in a floating point number $a \times 2^{b}$) run out very quickly. More cruelly, if you use [perturbation theory](http://www.science.eclipse.co.uk/sft_maths.pdf)
(which I will get to shortly), the limited bits in the exponent get you. This second constraint is only noticable after you have done a great deal of work writing a complicated WebGL shader, computed a reference orbit using an arbitrary precision library, and then passed that reference to the shader as a texture, and I suspect that when people get this far and find that they can't zoom in much farther, they have historically given up.

## Julia Morphing

Why is it important to be able to zoom to radiuses that are too small to represent in a 32 bit float? Julia morphing! When zooming in to the Mandelbrot Set, if you zoom near the edge of a miniature Mandelbrot Set, you will see tiny approximate Julia Sets scattered about. If you zoom in to the middle of these Julia Sets, you find more Mandelbrot Sets. However, if you zoom off center, a crazy thing happens: you eventually find a double copy of the Julia Set you picked, but doubled _around_ the point you picked. Repeat this enough times, and you can control the image- and control enables creativity. There is a [whole art scene](https://mathr.co.uk/web/m-artists.html#3rd-Order-Evolution) devoted to creating images by zooming in this way, but it's currently pretty inaccessible: most tools not only need to be downloaded, but also compiled. How can we bring this experience to the browser, to any iphone that visits a website?

## The problem, in detail

\fig{Float_example.svg.png}

A 32 bit float has 23 bits of precision in the mantissa. If each click zooms in by a factor of two, this means that a naive shader can only handle 23 clicks before every pixel on the screen is represented by the same pair of numbers, which is no good. In a clever shader, instead of representing each pixel by its coordinates in the Mandelbrot Set, each pixel is represented by its difference from the center pixel. Then, as long as you have the trajectory of the center pixel stored (in my case, computed on the CPU using a WASM distribution of gmp), you can compute the trajactory of the each other pixel by

$$z_{n + 1} + \Delta z_{n + 1} = (z_n + \Delta z_n)^2 + c + \Delta c$$


$$z_{n + 1} + \Delta z_{n + 1} = z_n^2 + 2 z_n \Delta z_n + \Delta z_n^2 + c + \Delta c$$

use $z_{n + 1} = z_n^2 + c$

$$z_{n + 1} + \Delta z_{n + 1} = z_{n + 1}  + 2 z_n \Delta z_n + \Delta z_n^2 + \Delta c$$
$$\Delta z_{n + 1} = 2 z_n \Delta z_n + \Delta z_n^2 + \Delta c$$

By computing $\Delta z$ this way, it's fine that the representation of $\Delta z$ only has a 23 bit mantissa. However, now we are limited  by the exponent. The smallest nonzero number that a 32 bit float can handle is $2^{-2^7}$, and materially, that's only 127 clicks of zooming. The funky S at the top of this post required 303 clicks, so if we tried to render it with the clever approach listed above, every pixel's $\Delta z$ would just be 0.

## An elegant solution that I reject

The right way to handle this is to give up on hardware floating point, and move to soft floats. You can store the mantissa in one 32 bit int, the exponent in another, and then make nice functions that do all the bit shifting and logic to implement ieee math. This is what early very deep mandelbrot zooms did, and real high quality mandelbrot explorers like Kalles Fraktaller and Imagina still fall back to this in some circumstances, but it's slow. They can afford this slowness because they only need soft floats once their CUDA, 64 bit shaders have run out of exponent, which takes thousands of clicks. I want to be able to zip around mildly deep in the mandelbrot set in my iphone's browser, so I need another answer.

## An ugly hack that's cool and fun

First, we note that in the update equation

$$\Delta z_{n + 1} = 2 z_n \Delta z_n + \Delta z_n^2 + \Delta c$$

there are a few ways that $\Delta z$ can change magnitude. The scariest way is a catastrophic cancellation between terms- this corresponds to the orbit of the current pixel diverging from the orbit of the center pixel, and is prevented using a recently discovered trick, [rebasing](https://fractalforums.org/fractal-mathematics-and-new-theories/28/another-solution-to-perturbation-glitches/4360/msg29835#msg29835). Second, there can be a non-catastrophic cancellation or addition that changes the magnitude of $\Delta z$ by a small factor. The third way is for $z_n$ to be very close to zero. If we handle all of these cases, we don't need to handle the full float specification. 

We store $\Delta_z$ an exponent (q) and mantissas (dx, dy). They are allowed to drift away from the range [.5, 1) unlike standard mantissas. For each iteration of 

$$\Delta z_{n + 1} = 2 z_n \Delta z_n + \Delta z_n^2 + \Delta c$$

we precompute the result exponent as just q + os, the exponent of the first term, which is much simpler than fully correct ieee float math. As long as the exponent is close enough to correct, (ie, right to within +- 127 or so) this works fine.

Then, we can calculate the mantissas by scaling the latter two terms to match the first. 

```
float x = get_orbit_x(k);
float y = get_orbit_y(k);
float os = get_orbit_scale(k);
dcx = delta[0] * pow(2., float(-q + cq - int(os)));
dcy = delta[1] * pow(2., float(-q + cq - int(os)));
float unS = pow(2., float(q) -os);

float tx = 2. * x * dx - 2. * y * dy + unS  * dx * dx - unS * dy * dy + dcx;
dy = 2. * x * dy + 2. * y * dx + unS * 2. * dx * dy +  dcy;
dx = tx;

q = q + int(os);
```

Now, we have handled the case of $z_n$ being small explicitly, and declared catastrophic cancellations to not happen. All that is left is to handle the mantissas drifting away from the range [.5, 1). 

```
if ( dx * dx + dy * dy > 1000000.) {
    dx = dx / 2.;
    dy = dy / 2.;
    q = q + 1;
  }
```

We keep a ...loose hold on them. Keeping the magnitude of the mantissa under 1000 instead of under 1 empirically reduces visual glitches resulting from the lack of subnormal float math on the GPU, and checking that it's not underflowing empirically can be omitted, but I don't fully know why and hope to find out in a later blog post!

The full shader code, along with the rest of the owl, is at

[https://github.com/HastingsGreer/mandeljs](https://github.com/HastingsGreer/mandeljs)

Finally, this work was closely inspired by [Claude's article on the same topic](https://mathr.co.uk/blog/2021-05-14_deep_zoom_theory_and_practice.html#a2021-05-14_deep_zoom_theory_and_practice_rescaling), and for absurdly deep Mandelbrot zooms in the browser, his [online explorer](https://fraktaler.mathr.co.uk/live/latest/), while not GPU accelerated, wins out thanks to Newton Raphsom zooming and Bilinear Approximation.



