

@def title = "Trebuchet Simulator"
@def hascode = true
@def rss = "Trebuchet Simulator"
@def rss_title = "Mandelbrot"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]


# Trebuchet Simulator
\fig{SimScreenshot.png}

[Try Now](https://jstreb.hgreer.com)

[Github repo](https://github.com/HastingsGreer/jstreb)

# Part 1: Simulating a trebuchet

Basically, this app follows this paper: 

# Part 2: Optimizing a trebuchet using a CMAES variant

I stumbled into a much simpler variant of Covariance Matrix Adaptation Evolutionary Search while implementing this app, and figure I might as well document it here.

Basically, the most naive way to optimize a function is to repeatedly sample from a distrubution $\mathcal{N} (best point, 1)$, updating best point whenever you find a new best point.


CMAES suggests repeatedly sampling 



