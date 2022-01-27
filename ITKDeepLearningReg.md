# Why you should use an itk Transform as the output of your deep registration library


## Need for a standard


## Need to handle image spacings, orientations, and origins

Before incorporating registration into downstream research code, we need to face two truths:

A: The downstream code needs to handle image orientation and spacing correctly

B: You do _not_ want to handle these properties in your deep learning code


I know itk it a heavy dependency, but hear me out.

People on the medical side want to express positions in physical coordinates: they want to express the location of markers,
measure the size of tumors, and register images of different modalities and resolutions

The correct resolution for a registration algorithm depends on the approach. It's not unusual to want to 
switch between, say, voxelmorph running at 64 x 64 x 64 and demons running at 32 x 32 x 32

If we want registration algorithms to be swappable, then the api has to be resolution agnostic

The only canidate api that is convenient for application developers to build on is in physical coordinates

(This is different from segmentation, where as long as your algorithm 

## The current state

Currently, deformations are either expressed in pixels, or 1 / resolutions, or sometimes 2 / resolutions
is identitymap added or not?
what is the order of vectors?



## You don't want to write this code every time you marry a registration algorithm to an application

A) it is a waste of effort

B) Mistakes are inevitable

## A solution: itkTransform as a lingua franca between registration algorithms and application code


