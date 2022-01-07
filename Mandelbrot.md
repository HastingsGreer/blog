
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
trajectories of mandelbrot points, without having to use arbitrary precision arithmetic throughout.
The "go to" source for the concept is [this pdf](http://www.science.eclipse.co.uk/sft_maths.pdf) by K. I. Martin. 
It's an excellent read, you should be reading that instead of this blog post.

\fig{/assets/Mandelbrot/python_screenshot2.png}

The integration between OpenCL and python is not that smooth: there's a ton of boilerplate, and you have to carefully match up the datatypes of buffers: any typer errors are not caught at runtime, 



## Julia


### GtkReactive

I enjoyed this model for UI development, but it is not still developed. Its spiritual successor is GTKObservables, which I need to go try.

It made it easy to add UI components for adjusting resolution, colormap details, etc, which I handled with keyboard shortkeys in the python version. Much better user experience!

\fig{/assets/Mandelbrot/julia_gui.png}

### Perturbative methods?

The main downside of the technique in the python method above is that it needs a good "center" point to compute in high precision, before computing low precision offsets: if the high precision trajectory escapes, we can't take offsets from it for very long.
In the julia code, we now take a more sensible approach and itertively seek out a good center

### Automatic zooming



## Julia and quadtree adaptive rendering

This is a proper adventure now: thi

\fig{/assets/Mandelbrot/julia-quadtree.png}
