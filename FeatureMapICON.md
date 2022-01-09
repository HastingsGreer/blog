

@def title = "Feature Map Inverse Consistency"
@def hascode = true
@def rss = "An exploration of inverse consistency for driving image registration"
@def rss_title = "Feature Map Inverse Consistency"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]

# Feature Map Inverse Consistency
\toc

This isn't a finished post, I'm just musing as I begin to write this up
## Loss definition

\begin{align}
\mathcal{L} &= \sum_{i \in I^A} \log \sum_{j \in I^B} 
    \frac{
        e^{
            \tilde{F}^A_i \cdot \dot{F}^B_j
        }
    }{
        \sum_{k \in I^B}
        e^{
            \tilde{F}^A_i \cdot \dot{F}^B_k
        }
}    
    \frac{
        e^{
            \hat{F}^A_i \cdot \check{F}^B_j
        }
    }{
        \sum_{k \in I^A}
        e^{
            \hat{F}^A_k \cdot \check{F}^B_j
        }
} \\
\text{equivalently} & \\
\mathcal{L} &= \text{log} ~ \text{P}[\Phi^{AB} \circ \Phi^{BA} (x) = x ] \\
\mathcal{L} &= \sum_{row} \log \sum_{col} 
    \text{softmax}_{row} 
        (\tilde{F}^A {\dot{F}^{BT}} ) 
    \text{softmax}_{col} 
        (\hat{F}^A {\check{F}^{BT}} ) 
\end{align}

Notational weirdness: $\tilde{F}, \dot{F}, \hat{F}, \text{and} ~  \check{F}$ are four independent draws from the random equivariance augmentation

## Equivariant Augmentation

Warp it, process it with neural network unwarp it. If network is equvariant, this is no different than just processing it with the neural network. Otherwise, the network is ~ ~ punished ~ ~ . 

## Different forms of Augmentation

The overall story of training networks using the FeatureMapICON loss is as follows: 
If we use a network that is inherently equivariant, by operating on patches individually and independently, then we don't have enough learning power, and have to deal with a tradeoff between the receptive field of the network and the degree of cropping done in the network.
If we use a network that has a great deal of downsampling and then upsampling, then we get lots of power, but the network just learns the indentity map by outputting a specific vector for each pixel location, with no dependence on input images.
However, we can solve this by modifying the loss by inserting augmentation in a specific way to force equivariance, as above

## Restricting features output by the network to the ball

The network wants to output vectors of the same manitude everywhere, otherwise if a pixel has a big vector, then that will have a large do product with *all* the vectors with similar direction, which is not one-to-one, and so not inverse consistent, and so is penalized. As a result, we don't technically need to normalize our feature vectors to constant magnitude. However, the network has to use significant capacity to do its normalization itself, and so we can speed training by doing the normalization explicitly, followed by scaling by some radius $\lambda$ which is a trainable parameter. $\lambda$ should start around 12.


\fig{/assets/FeatureMapICON/FeatureNormScale.jpg}

Specifically, we compute the magnitude of each feature vector (shown in red above), divide that feature vector by its magnitude, then multiply by a scale, named $\lambda$ .

## Attempt 0 to force equivariance: Don't

\fig{/assets/FeatureMapICON/equivariance.png}

Result: The network outputs a fixed vector at each pixel coordinate

Then, $F^A_i \cdot F^B_j$ approximates $ \lambda^2 \delta_{ij}$ independent of the data.

Then, 


\begin{align}
\mathcal{L} &= \sum_{i \in I^A} \log \sum_{j \in I^B} 
    \frac{
        e^{
            \lambda^2 \delta_{ij}
        }
    }{
        \sum_{k \in I^B}
        e^{
            \lambda^2 \delta_{ik}
        }
}    
    \frac{
        e^{
            \lambda^2 \delta_{ij}
        }
    }{
        \sum_{k \in I^B}
        e^{
            \lambda^2 \delta_{kj}
        }
} \\    
&= \sum_{i \in I^A} \log \sum_{j \in I^B} \delta_{ij}
\\
&= 0 , 
\end{align}

scoring a perfect loss (log P = 0, P = 1) while learning nothing.

## Attempt 1 to force equivariance: Small affine warps


### The process: 

Resample the image by a matrix
$$ T =  \left(\begin{array}{rr}1 & 0 & 0 \\0 & 1 & 0 \\0 & 0 & 1\end{array}\right) 
 + .05 
\left(\begin{array}{r} & \mathcal{N}_{  (2, 3)} & \\0 & 0 & 0\end{array}\right) 
$$

Apply the neural network

Resample the features by $ T^{-1}$

### The result:

The goal here is to suppress the failure mode laid out in Attempt 0. Let's investigate whether outputting a fixed feature vector for each location still scores well in the loss.

We can approximate the augmentation $\tilde{\cdot}$ as a permutation $\tilde{P}^{-1}$ that permutes the pixels or features input into it- 
(this is not quite true, as for example the affine warp linearly combines some features / pixels when interpolating, and discards some features / pixels that are moved off the edge of the screen)

\begin{align}
\mathcal{L} &= \sum_{i \in I^A} \log \sum_{j \in I^B} (\tilde{P}\dot{P}^{-1} \odot \hat{P}\check{P}^{-1})_{ij}
\\
&\rightarrow -\infty 
\end{align}

It looks like we are in no danger of outputting fixed vectors!

With the failure mode from attempt zero suppressed, 
training initially proceeds well, and we get the first few results that look reasonable on the downstream task we are using for evaluation, DAVIS semi-supervised instance segmentation.


\fig{/assets/FeatureMapICON/camel_figure.png}

However, a new issue appears: the neural network trains well for a while,
but eventually we see again that the loss improves while the accuracy gets worse.
The reason is that the network begins having specific distributions of vectors for each part of the image,
so that it never matches pixels further apart than the affine warping can move them: the

## Attempt 2: force each pixel location to have the same per channel mean

\fig{/assets/FeatureMapICON/PixelCenter.jpg}

### The process: 

After processing with the neural network, subtract the mean from each batch of pixels. (shown in red above). 
This is similar to batch normalization, 
except computing the mean over the whole batch, 
but individually for each pixel location instead of over the whole batch and every pixel location.




## Attempt 3: Rolling Augmentation

In the previous approach, we attempted to force the neural network outputs to have the same statistics at each pixel. 
Because we were doing this at a batch level, we went with forcing just the mean to be the same at every pixel, instead of forcing the whole distribution to be identical. Eventually, the network began defeating this, although I do not know how: it was storing the rough  location in the variance, or the correlation, or something else clever.
That approach can be interpreted as "measuring the statistics before augmentation". However, after some thought, I realized that there was a way to force the per pixel statistics to be the same at every pixel after augmentation, instead of before: when picking a distribution of "augmentation permutations" P, pick one that moves each pixel to each other pixel with uniform probability. Then, by force after augmentation, every pixel in the image has the same distribution of feature vectors.

The simplest form of augmentation with this property is "rolling": sliding the image left to right and up and down by some random amount, wrapping at the edges (ie, implemented as np.roll). (Implementing this performantly and independently for each channel is slightly more involved in torch). Empirically, this approach works to prevent the network from only matching vectors that are in the same region of the image by making the distribution of vectors the same at each pixel location: 

Assertion: the output of the pipeline

```
Sample x and y rolling amounts from 0 .. [edge length - 1]
roll image by x in the x direction, y in the y direction
Process into feature vectors using neural network
roll features by -x, -y
```

has the same distribution of feature vectors at every pixel location

Proof: 
Proof fails: the neural network could learn to detect the amount of rolling. Argh

So, why is this approach effective?

\fig{/assets/FeatureMapICON/rolling.png}


