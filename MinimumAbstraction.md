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

There are several operations we want to implement for all our transform objects: we want to we want to be able to warp an image using a transform, we want to transform a point, and we want to be able to compose two transforms. Ideally, we'd like to be able to invert a transform.

## Before and After

Before:

```python
class InverseConsistentAffineDeformableNet(nn.Module):
    def __init__(self, affine_network, network, lmbda, input_shape):
        super(InverseConsistentAffineDeformableNet, self).__init__()

        self.sz = np.array(input_shape)
        self.spacing = 1.0 / (self.sz[2::] - 1)

        _id = identity_map_multiN(self.sz, self.spacing)
        self.register_buffer("identityMap", torch.from_numpy(_id))

        _id_projective = np.concatenate([_id, np.ones(input_shape)], axis=1)
        self.register_buffer(
            "identityMapProjective", torch.from_numpy(_id_projective).float()
        )

        self.map_shape = self.identityMap.shape

        self.affine_regis_net = affine_network
        self.regis_net = network

        self.lmbda = lmbda

    def adjust_batch_size(self, BATCH_SIZE):
        self.sz[0] = BATCH_SIZE
        self.spacing = 1.0 / (self.sz[2::] - 1)

        _id = identity_map_multiN(self.sz, self.spacing)
        self.register_buffer("identityMap", torch.from_numpy(_id))

        _id_projective = np.concatenate([_id, np.ones(self.sz)], axis=1)
        self.register_buffer(
            "identityMapProjective", torch.from_numpy(_id_projective).float()
        )

    def forward(self, image_A, image_B):
        # Compute Displacement Maps

        if len(self.spacing) == 2:
            batch_matrix_multiply = "ijkl,imj->imkl"
            padding_array = (0, 0, 0, 0, 0, 1)
        else:
            batch_matrix_multiply = "ijkln,imj->imkln"
            padding_array =  (0, 0, 0, 0, 0, 0, 0, 1)
        
        self.matrix_AB = self.affine_regis_net(image_A, image_B)

        self.phi_AB_affine = torch.einsum(
            batch_matrix_multiply, self.identityMapProjective, self.matrix_AB
        )

        self.phi_AB_affine_inv = torch.einsum(
            batch_matrix_multiply,
            self.identityMapProjective,
            torch.inverse(self.matrix_AB),
        )

        self.matrix_BA = self.affine_regis_net(image_B, image_A)

        self.phi_BA_affine = torch.einsum(
            batch_matrix_multiply, self.identityMapProjective, self.matrix_BA
        )

        self.phi_BA_affine_inv = torch.einsum(
            batch_matrix_multiply,
            self.identityMapProjective,
            torch.inverse(self.matrix_BA),
        )

        # resample using affine for deformable step. Use inverse to get residue in correct coordinate space

        self.affine_warped_image_B = compute_warped_image_multiNC(
            image_B, self.phi_AB_affine_inv[:, :len(self.spacing)], self.spacing, 1
        )

        self.affine_warped_image_A = compute_warped_image_multiNC(
            image_A, self.phi_BA_affine_inv[:, :len(self.spacing)], self.spacing, 1
        )

        self.D_AB = nn.functional.pad(
            self.regis_net(image_A, self.affine_warped_image_B), padding_array
        )
        self.phi_AB = self.phi_AB_affine + self.D_AB

        self.D_BA = nn.functional.pad(
            self.regis_net(image_B, self.affine_warped_image_A), padding_array
        )
        self.phi_BA = self.phi_BA_affine + self.D_BA

        # Compute Image similarity

        self.warped_image_A = compute_warped_image_multiNC(
            image_A, self.phi_AB[:, :len(self.spacing)], self.spacing, 1
        )

        self.warped_image_B = compute_warped_image_multiNC(
            image_B, self.phi_BA[:, :len(self.spacing)], self.spacing, 1
        )

        similarity_loss = torch.mean((self.warped_image_A - image_B) ** 2) + torch.mean(
            (self.warped_image_B - image_A) ** 2
        )

        # Compute Inverse Consistency
        # One way

        self.approximate_zero = (
            torch.einsum(batch_matrix_multiply, self.phi_AB, self.matrix_BA)[:, :len(self.spacing)]
            + compute_warped_image_multiNC(
                self.D_BA[:, :len(self.spacing)], self.phi_AB[:, :len(self.spacing)], self.spacing, 1
            )
            - self.identityMap
        )
        self.approximate_zero2 = (
            torch.einsum(batch_matrix_multiply, self.phi_BA, self.matrix_AB)[:, :len(self.spacing)]
            + compute_warped_image_multiNC(
                self.D_AB[:, :len(self.spacing)], self.phi_BA[:, :len(self.spacing)], self.spacing, 1
            )
            - self.identityMap
        )
        inverse_consistency_loss = self.lmbda * torch.mean(
            (self.approximate_zero) ** 2 + (self.approximate_zero2) ** 2
        )
        transform_magnitude = self.lmbda * torch.mean(
            (self.identityMap - self.phi_AB[:, :len(self.spacing)]) ** 2
        )
        self.all_loss = inverse_consistency_loss + similarity_loss
        return [
            x
            for x in (
                self.all_loss,
                inverse_consistency_loss,
                similarity_loss,
                transform_magnitude,
            )
        ]
```

After:
```


## 'Bad' code: the starting point

My initial 'Bad' code implemented two kinds of geometric transform: linear transforms, and arbitrary warps. 
### Affine Transforms

The correct way to represent an affine transform comes carved in stone from the mathematicians: This should be an N + 1 x N + 1 matrix.

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

The other 



# Detritus

I work in the field of [Image Registration](https://en.wikipedia.org/wiki/Image_registration) 


