
@def title = "footsteps"
@def hascode = true
@def rss = "footsteps"
@def rss_title = "footsteps"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]


# footsteps.py: experiment logging for the lazy





```bash
pip install footsteps
```

```python
import footsteps
import matplotlib.pyplot as plt
plt.plot(my_results)
plt.savefig(footsteps.output_dir + "MyCoolResults.png")
```
## Footsteps

A non-configurable experiment logging package.

Footsteps is designed so that it takes minimal effort to keep track of what code generated what result, even if you are writing a five line throwaway script. Then, 3 years later when you are trying to understand how you generated that figure or trained that network, you have enough information to follow your footsteps and work out exactly what you did.

### Philosophy

I have found that when I am writing code to perform experiments, I have had to answer the question "Where do I want to save this file" over and over again. Furthermore, I found myself (and many others) re-writing the same code and fixing the same mistakes for each project. 

First, a file is just saved to an absolute or relative path, "weights.ext", "threespheres.png". This immediately becomes a nightmare as running one experiment overwrites the results of the last one.  

In the next iteration, perhaps the date and time is prepended to the path, as recommended by the official tensorboard documentation. This begins to work, however the code that specifies how to turn the current time into a file path ends up duplicated and dotted throughout the code, or every function gains a parameter "output_dir" or "logger." 

Experiment reproduction is hard at two points in time: First, when doing an experiment, it is easy to lack the motivation to meticulously record what you are doing, including details such as package versions or code changes that you may not think are important. Second, when trying to reproduce an experiment, motivation is available in abundance, but the information needed may no longer exist.

To solve this problem, footsteps is designed to require as little motivation as possible at experiment time, and to provide as much information as possible at reproduction time.

### Usage

To use footsteps, just import the package. At runtime, this will prompt the user for a descriptive name to be assosciated with any artifacts generated by this iteration of your code. Then, it will create a directory using that name, dump information into "info.txt" in that directory including the current git hash, command and arguments, which python env is in use etc into that directory. Finally, the path to this directory is available as `footsteps.output_dir`, so that the rest of your code knows where to put any artifacts that it generates.

This is a one file package with no configuration. In the event that a project using footsteps grows to the point where you want to configure or specialize footsteps, the recommended process is to copy footsteps/footsteps.py into your codebase, modify it to make any changes you need, and import that instead of this.

### Information recorded

- The command used to start python, including the name of the script and any command line arguments
- The system that the code is running on
- The python executable used.
- The current git hash
- Any uncommitted changes to the code