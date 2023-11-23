
@def title = "Stable Affine Alignment"
@def hascode = true
@def rss = ""
@def rss_title = "Stable Affine Alignment"
@def rss_pubdate = Date(2023, 10, 15)

@def tags = ["syntax", "code", "image"]

# Stable Affine Alignment

\toc

It is a well known but unpublished fact of image registration that if you want to compute the wibbly wobbly vector field that align two images, it's as easy as training a U-Net to output that field directly. However, if you want to predict a rigid or affine transform between two images, the equivalant method "Just predict the matrix" is horribly unstable. 
