
@def title = "Javascript Mandelbrot"
@def hascode = true
@def rss = "My projects that render the Mandelbrot Set with various techniques"
@def rss_title = "Mandelbrot"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]

# The fastest Javascript Mandelbrot in the land

\fig{S_shape.png}
```
re=-1.7690814562274050315843767105557415995678255069426278146980259620139710642566655442009374834559214525490298159;
im=0.00303778715253911967339488181941274068102374494645866031674381946201892057134148878778176962091542987845068523;
r=0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006136366831622158191
```



Before anything else, 
[get going, explore the Mandelbrot Set!](https://hastingsgreer.github.io/mandeljs)

In early 2023, there was a gap in online Mandelbrot Set explorers. People had written fast, GPU based Mandelbrot Set renderers such as [], but they only let you click a few times before you reached the bottom and ran into pixels. The
reason is that WebGL only has 32 bit floats, and this is just not very much precision for Mandelbrot zooming. This hurts twice: First, if you naively compute $z_{n + 1} = z_n$ in a shader, the limited bits in the mantissa (that is, the "a" in a floating point number $a \times 2^{b}$) run out very quickly. More cruelly, if you use [perturbative approximation](http://www.science.eclipse.co.uk/sft_maths.pdf)
(which I will get to shortly), the limited bits in the exponent get you. This second constraint is only noticable after you have done a great deal of work writing a complicated WebGL shader, computed a reference orbit using an arbitrary precision library, and then passed that reference to the shader as a texture, and I suspect that when people get this far and find that they can't zoom in much farther, they have historically given up.

## Julia Morphing

Why is it important to be able to zoom to radiuses that are too small to represent in a 32 bit float? Julia morphing! When zooming in to the Mandelbrot Set, if you zoom near the edge of a miniature Mandelbrot Set, you will see tiny approximate Julia Sets scattered about. If you zoom in to the middle of these Julia Sets, you find more Mandelbrot Sets. However, if you zoom off center, a crazy thing happens: you eventually find a double copy of the Julia Set you picked, but doubled _around_ the point you picked. Repeat this enough times, and you can control the image- and control enables creativity. There is a [whole art scene](https://mathr.co.uk/web/m-artists.html#3rd-Order-Evolution) devoted to creating images by zooming in this way, but it's currently pretty inaccessible: most tools not only need to be downloaded, but also compiled. How can we bring this experience to the browser, to any iphone that visits a website?

## The problem, in detail

\fig{float_example.svg.png}

A 32 bit float has 23 bits of precision in the mantissa. If each click zooms in by a factor of two, this means that a naive shader can only handle 23 clicks before every pixel on the screen is represented by the same pair of numbers, which is no good. In a clever shader, instead of representing each pixel by its coordinates in the Mandelbrot Set, each pixel is represented by its difference from the center pixel. Then, as long as you have the trajectory of the center pixel stored (in my case, computed on the CPU using a WASM distribution of gmp), you can compute the trajactory of the each other pixel by

$$z_{n + 1} + \Delta z_{n + 1} = (z_n + \Delta z_n)^2 + c + \Delta c$$


$$z_{n + 1} + \Delta z_{n + 1} = z_n^2 + 2 z_n \Delta z_n + \Delta z_n^2 + c + \Delta c$$

use $z_{n + 1} = z_n^2 + c$

$$z_{n + 1} + \Delta z_{n + 1} = z_{n + 1}  + 2 z_n \Delta z_n + \Delta z_n^2 + \Delta c$$
$$\Delta z_{n + 1} = 2 z_n \Delta z_n + \Delta z_n^2 + \Delta c$$

By computing $\Delta z$ this way, it's fine that the representation of $\Delta z$ only has a 23 bit mantissa. However, now we are limited  by the exponent. The smallest nonzero number that a 32 bit float can handle is $2^{-2^7}$, and materially, that's only 127 clicks of zooming. The funky S at the top of this post required 303 clicks, so if we tried to render it with the clever approach listed above, every pixel's $\Delta z$ would just be 0.

## An elegant solution that I reject

The right way to handle this is to give up on hardware floating point, and move to soft floats. You can store the mantissa in one 32 bit int, the exponent in another, and then make nice functions that do all the bit shifting and logic to implement ieee math. This is what the real high quality mandelbrot explorers like Kalles Fraktaller and Imagina do, but it's slooooww. They can afford this slowness because they only need soft floats once their CUDA, 64 bit shaders have run out of exponent, which takes thousands of clicks. I want to be able to zip around mildly deep in the mandelbrot set in my iphone's browser, so I need another answer.

## An ugly hack that's cool and fun

My insight is that if I was to do correct soft float math, all the trajectories of the individual pixels would get bit shifted at the same time, and so instead of laboriously computing this 250,000 times per iteration, once per pixel, I can compute the shifts once on the CPU and store them in my data texture. This is only mostly correct, but it allows soft "floats" at interactive speed, and that's worth something.   

```
    const fsSource = `#version 300 es
precision highp float;
in highp vec2 delta;
out vec4 fragColor;
uniform vec4 uState;
uniform vec4 poly1;
uniform vec4 poly2;
uniform sampler2D sequence;
float get_orbit_x(int i) {
  i = i * 3;
  int row = i / 1024;
  return texelFetch(sequence, ivec2( i % 1024, row), 0)[0];
}
float get_orbit_y(int i) {
  i = i * 3 + 1;
  int row = i / 1024;
  return texelFetch(sequence, ivec2( i % 1024, row), 0)[0];
}
float get_orbit_scale(int i) {
  i = i * 3 + 2;
  int row = i / 1024;
  return texelFetch(sequence, ivec2( i % 1024, row), 0)[0];
}
void main() {
  int q = int(uState[2]) - 1;
  int cq = q;
  q = q + int(poly2[3]);
  float S = pow(2., float(q));
  float dcx = delta[0];
  float dcy = delta[1];
  float x;
  float y;
  // dx + dyi = (p0 + p1 i) * (dcx, dcy) + (p2 + p3i) * (dcx + dcy * i) * (dcx + dcy * i)
  float sqrx =  (dcx * dcx - dcy * dcy);
  float sqry =  (2. * dcx * dcy);

  float cux =  (dcx * sqrx - dcy * sqry);
  float cuy =  (dcx * sqry + dcy * sqrx);
  float dx = poly1[0]  * dcx - poly1[1] *  dcy + poly1[2] * sqrx - poly1[3] * sqry ;// + poly2[0] * cux - poly2[1] * cuy;
  float dy = poly1[0] *  dcy + poly1[1] *  dcx + poly1[2] * sqry + poly1[3] * sqrx ;//+ poly2[0] * cuy + poly2[1] * cux;
      
  int k = int(poly2[2]);

  if (false) {
      q = cq;
      dx = 0.;
      dy = 0.;
      k = 0;
  }
  int j = k;
  x = get_orbit_x(k);
  y = get_orbit_y(k);
  
  for (int i = k; float(i) < uState[3]; i++){
    j += 1;
    k += 1;
    float os = get_orbit_scale(k - 1);
    dcx = delta[0] * pow(2., float(-q + cq - int(os)));
    dcy = delta[1] * pow(2., float(-q + cq - int(os)));
    float unS = pow(2., float(q) -get_orbit_scale(k - 1));

    float tx = 2. * x * dx - 2. * y * dy + unS  * dx * dx - unS * dy * dy + dcx;
    dy = 2. * x * dy + 2. * y * dx + unS * 2. * dx * dy +  dcy;
    dx = tx;

    q = q + int(os);
    S = pow(2., float(q));

    x = get_orbit_x(k);
    y = get_orbit_y(k);
    float fx = x * pow(2., get_orbit_scale(k)) + S * dx;
    float fy = y * pow(2., get_orbit_scale(k))+ S * dy;
    if (fx * fx + fy * fy > 4.){
      break;
    }
    if ( true && dx * dx + dy * dy > 4.) {
      dx = dx / 2.;
      dy = dy / 2.;
      q = q + 1;
      S = pow(2., float(q));
      dcx = delta[0] * pow(2., float(-q + cq));
      dcy = delta[1] * pow(2., float(-q + cq));
    }
    if ( false && dx * dx + dy * dy < .25) {
      dx = dx * 2.;
      dy = dy * 2.;
      q = q - 1;
      S = pow(2., float(q));
      dcx = delta[0] * pow(2., float(-q + cq));
      dcy = delta[1] * pow(2., float(-q + cq));
    }

    if (true  && fx * fx + fy * fy < S * S * dx * dx + S * S * dy * dy || (x == -1. && y == -1.)) {
      dx  = fx;
      dy = fy;
      q = 0;
      S = pow(2., float(q));
      dcx = delta[0] * pow(2., float(-q + cq));
      dcy = delta[1] * pow(2., float(-q + cq));
      k = 0;
      x = get_orbit_x(0);
      y = get_orbit_y(0);
    }
  }
  float c = (uState[3] - float(j)) / uState[1];
  fragColor = vec4(vec3(cos(c), cos(1.1214 * c) , cos(.8 * c)) / -2. + .5, 1.);
}
```

[JS repository](https://github.com/HastingsGreer/mandeljs)
