
@def title = "Mandelbrot"
@def hascode = true
@def rss = "My projects that render the Mandelbrot set with various techniques"
@def rss_title = "Mandelbrot"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]

# Rendering the Mandelbrot Set

\toc

---

[Python repository](https://github.com/HastingsGreer/MandelBrotGL)

[Julia repository](https://github.com/HastingsGreer/julia_mandelbrot)

## Early efforts: Python and OpenCL

\fig{/assets/Mandelbrot/python_screenshot.png}

This was my first effort at rendering the mandelbrot set, fast.
The program allows switching between numpy, opencl, and c for computing the images. 
Matplotlib is used for the GUI.

The really neat trick is perturbative rendering: this is a technique for computing high precision 

\fig{/assets/Mandelbrot/python_screenshot2.png}
## Julia and perturbative rendering


### GtkReactive

I enjoyed this model for UI development, but I'm not sure it's still developed?

### Perturbative methods?

The main downside of the technique in the python method above is that it needs a good "center" point to compute in high precision, before computing low precision offsets: if the high precision trajectory escapes, we can't take offsets from it for very long.
In the julia code, we now take a more sensible approach and itertively seek out a good center

## Julia and quadtree adaptive rendering!!

This is a proper adventure now: thi

\fig{/assets/Mandelbrot/julia-quadtree.png}
