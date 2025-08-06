# This file was generated, do not modify it. # hide
#hideall
using PyCall #hide
buf = IOBuffer(); #hide
pyimport("sys").stdout = buf; #hide
pyimport("sys").output = @OUTPUT
print(String(take!(buf))) #hide
pyimport_conda("scipy", "scipy") #hide
