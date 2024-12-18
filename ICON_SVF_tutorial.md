# How to write your own registration model

This document explains how to write a novel registration method in the ICON framework. 

<!-- We will assume that neural network driven stationary velocity field registration (SVF) does not already exist in icon_registration.) -->

## Writing a similarity measure

Similarity measures in `icon_registration` are python functions that take two pytorch tensors representing batches of images. These pytorch channels have two channels: the first channel is image intensity.

The second channel is 1 if the intensity at that voxel is interpolated, or zero otherwise. For some types of images, it is useful to disregard image similarity in extrapolated regions of a warped image. For images with a black background such as skull-stripped brains, this is not necessary.

We will implement a simple ssd similarity:
```python
def ssd_similarity(image_A, image_B):
	# since we are not using the interpolation information, we strip it off before computing similarity.
	image_A, image_B = image_A[:, 0], image_B[:, 0]

	return torch.mean((image_A - image_B)**2)
```

## Writing a registration method

In order to write a registration method, we first have to understand how `icon_registration` represents a transform. In `icon_registration`, a transform is any python function that takes as input a tensor of coordinates, and returns those coordinates transformed. 

This is intended to closely conform to the mathematical notion of a transform: a function $\phi: \mathbb{R}^N \rightarrow \mathbb{R}^N$

This is an extremely flexible definition, since the transform controls how its internal parameters are used to warp coordinates. On the flip side, it means that transforms are responsible for knowing how to interpret their parameters.

The convention in icon is to store the parameters of the transform in the closure of the function; however an object oriented approach can also work. We will cover both options in this tutorial.

Now that we know how a transform is represented, we can define a registration method: A registration method is simply any torch module that takes two images as input to its `forward` method and returns a transform.

The registration methods available in `icon_registration` are defined in `icon_registration.network_wrappers.` 

They are named like "FunctionFromMatrix" or "FunctionFromVectorField" because they wrap an internal pytorch module that produces, for example, a matrix, from two images, and turn that matrix into a transform, ie a function.

So! Let us write a toy, euler integration based SVF registration.

Registration methods in `icon_registration` are subclasses of torch.nn.Module with the following api:
The forward method of a registration method take in two tensors representing batches of images, `image_A` and `image_B`, and returns a python function.

This corresponds to a mathematical notion of a registration method as an operator from a pair of images to a function: 

$$ \Phi: (( \mathbb{R}^N \rightarrow \mathbb{R}) \times (\mathbb{R}^N \rightarrow \mathbb{R})) \rightarrow (\mathbb{R}^N \rightarrow \mathbb{R}^N) $$

When we construct our FunctionFromStationaryVelocityField object, we will
pass in a pytorch module net that is responsible for generating the velocity
field from the input images. This way, it is easy experiment with different architectures.


### Object oriented stationary velocity field
```
class SVFTransform:
	def __init__(self, velocity_field, spacing, n_steps=16):
		self.n_steps = n_steps
		self.spacing = spacing
		self.velocity_delta = velocity_field / n_steps
	def __call__(self, coordinate_tensor):
		for _ in range(16):
			coordinate_tensor = coordinate_tensor + compute_warped_image_multiNC(
				self.velocity_delta, coordinate_tensor, self.spacing, 1)
		return coordinate_tensor

class FunctionFromStationaryVelocityField(torch.nn.Module):
	def __init__(self, net, n_steps=16):
		super(FunctionFromStationaryVelocityField, self).__init__()
		self.net = net
		self.n_steps = n_steps

	def forward(self, x, y):
		velocity_field = self.net(x, y)
		return SVFTransform(velocity_field, self.spacing, self.n_steps)
```

### Closure based stationary velocity field
```
class FunctionFromStationaryVelocityField(torch.nn.Module):
    def __init__(self, net, n_steps=16):
        super(FunctionFromStationaryVelocityField, self).__init__()
        self.net = net

    def forward(self, x, y):
        velocityfield_delta = self.net(x, y) / self.n_steps
        def transform(coordinate_tensor):
            for _ in range(self.n_steps):
              coordinate_tensor = input_ + compute_warped_image_multiNC( 
                velocityfield_delta, coordinate_tensor, self.spacing, 1)
            return coordinate_tensor
        return transform
```

I strongly prefer the latter stylistically, but the two are interchangeable.
		
