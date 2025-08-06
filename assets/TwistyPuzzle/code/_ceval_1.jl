# This file was generated, do not modify it. # hide
#hideall
using PyCall 
buf = IOBuffer(); 
pyimport("sys").stdout = buf; 
pyimport("sys").output = @OUTPUT 
pyimport_conda("scipy", "scipy") 
