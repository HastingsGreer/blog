#DONE
✓ put all results into the overleaf
✓ evaluate latest highres model
✓ train oai knees with LNCC + augmentation
✓ merge biag .vimrc
✓ train brain lncc
✓ ICON 1.0 release
✓ get OAI pull request merged
✓ merge code in "/media/data/hastings/InverseConsistency/" into master
✓ footsteps needs to log uncommitted file if that's what's being run

# TODO

## Cleanup todo

update `OAI_analysis_2` to ICON 1.0.0 

log sample registrations to tensorboard

log DICE metric to tensorboard

fix batchfunction callback- needs refactor

compress OAI models by dropping identitymaps

add identitymap stripping code to ICON

put augmentation into train.py

ICON default network

use better torch parallelism abastraction

investigate corner alignment (RIP LOL)

freeze network into asymmetricnet with fixed vectorfields

## Ambitious todo

train a diffusion model

train a VQ-GAN

genius idea: registration that improves previous result: train by randomy resetting prev result

try segmenting latest kaggle challenge

try registering latest kaggle challenge

99%ICON: ICON but the worst 1% of inverse consistencies aren't penalized

mixture of gaussians ICON:
	interpret ICON as "registration outputs a gaussian at each pixel, ICON loss is log odds of exact inverse consistency. 
	in that framework, rewrite to output a mixture of gaussians instead of a gaussian: perhaps can accurately model tearing?

need a synthetic dataset for tearing.

one approach to mitigate this is to create a very diverse zoo of intensity transfer functions for data augmentation, and hope that this forces the network to learn to register a larger complete set of transfer functions including MR -> CT even though that's not a strict 1-1 function [Adrien's paper](https://fairlydeep.slack.com/files/UKV1W0FDX/F03L71Z79PB/synthmorph_learning_contrast-invariant_registration_without_acquired_images.pdf)

## Marc request todo

download full copdgene image dataset

- currently training with just LNCC for taste. Will try next with LNCC + augmentation

train lung with lin loss + augmnentation

- put lin loss into losses.py- doesn't need to be embedded into GradientICON

make formal list of experiments for paper -- journal article?

put OAI preprocessing into pretrained models

Create a set of images where the shapes are bright and the background dark. Create another set where it is the other way around. Train a network that gets as inputs either a random image pair from one or from the other. Will this network entirely fail if it is presented with a pair where one image is from one set and the other one from the other?

non neural finetune

high res finetune lowres model

contour based image visualization

snap to grid

## ITK deficiencies todo

verify whether itk can be installed on an old version yet?

get itk to not segfault when asked to save a composite transform without []ifying it

get itkDisplacementFieldJacobianFilter wrapped for doubles
