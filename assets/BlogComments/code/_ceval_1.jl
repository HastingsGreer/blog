# This file was generated, do not modify it. # hide
using PyCall #hide
buf = IOBuffer(); #hide
pyimport("sys").stdout = buf; #hide
pyimport("sys").output = @OUTPUT #hide
py""" #hide
import os #hide
os.system(''' #hide
curl https://api.github.com/repos/HastingsGreer/blog/issues/2/comments \
 | grep -e "body\|login"
''') #hide
""" #hide
print(String(take!(buf))) #hide
