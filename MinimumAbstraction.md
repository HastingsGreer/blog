@def title = "Writing scientific code with the minimum of abstraction"
@def hascode = true
@def rss = "Writing scientific code with the minimum of abstraction"
@def rss_title = "Writing scientific code with the minimum of abstraction"
@def rss_pubdate = Date(2022, 2, 20)


# How to write better scientific code while fighting boilerplate

This post is a response to the article [How to write better scientific code in Python](https://zerowithdot.com/improve-data-science-code/) and the ensuing [Hacker News discussion](https://news.ycombinator.com/item?id=30397485).
I think that that article suffered from using a toy example, and so I am writing a similarly structured article using a real example.

## The task

While writing my paper [ICON: Learning regular maps through inverse consistency](https://arxiv.org/abs/2105.04459) I ran into a problem familiar to any object oriented data scientist: I needed to represent a mathematical object as a python object in a flexible way,
without my code ballooning in type complexity or becoming too rigid to experiment on. In my case, the mathematical object was a geometric transformation: a function $ \Phi^{-1} : \mathbb{R}^N \rightarrow \mathbb{R}^N $ which represents how to move each pixel in an image to warp it. 

There are a variety of different types of transforms, such as translations, rotations, and arbitrary warpings which specify where each individual pixel in the resulting image 

There are several operations we want to implement for all our transform objects: we want to we want to be able to warp an image using a transform, we want to transform a point, and we want to be able to compose two transforms. There are some transforms we can invert.

Ultimately this is a neural network project, and what will happen is a neural network will output a batch of transforms, which will have some loss computed on it.
## Before and After

Before:



## 'Bad' code: the starting point

My initial 'Bad' code implemented two kinds of geometric transform: linear transforms, and arbitrary warps. 
### Affine Transforms

The correct way to represent an affine transform comes carved in stone from the mathematicians: This should be an N + 1 x N + 1 matrix. (A batch of N + 1 x N + 1 matrices)

If pressed I could write a function for composing two linear transforms, I suspect anyone else would do it the same way:

```python
def compose_linear_transforms(transform_A, transform_B):
    return transform_A @ transform_B
```

However, the 'bad' programmer who doesn't really believe in types or abstraction would never do this. Why write `compose_linear_transforms(x, y)` when `x @ y` will do? 
Arguably, `@`  _is_ the function `compose_linear_transforms`. It is also the function `transform_point`.  

The function to warp an image using an affine map is slightly trickier. If we know the coordinates of each pixel in the input and output image, then it is well defined, and since we are bad programmers, lets just define the coordinates to range from -1 to 1 along each axis

```python
def warp_linear_transform(transform, image):
    
```



### Vector Field Transforms

The other common form of geometric transform for a neural network 



# Detritus

I work in the field of [Image Registration](https://en.wikipedia.org/wiki/Image_registration) 


