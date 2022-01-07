

@def title = "Feature Map Inverse Consistency"
@def hascode = true
@def rss = "An exploration of inverse consistency for driving image registration"
@def rss_title = "Feature Map Inverse Consistency"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]


# Feature Map Inverse Consistency

## Purpose of Rolling Augmentation

The overall story of training networks using the FeatureMapICON loss is as follows: 
If we use a network that is inherently equivariant, by operating on patches individually and independently, then we don't have enough learning power, and have to deal with a tradeoff between the receptive field of the network and the degree of cropping done in the network.
If we use a network that has a great deal of downsampling and then upsampling, then we get lots of power, but the network just learns the indentity map by outputting a specific vector for each pixel location, with no dependence on input images.
However, we can solve this by modifying the loss by inserting augmentation in a specific way to force equivariance.


