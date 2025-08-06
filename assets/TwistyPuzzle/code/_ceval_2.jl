# This file was generated, do not modify it. # hide
py""" #hide
import numpy as np
import matplotlib.pyplot as plt
import sys
state = np.eye(16)
display_matrix = []
for i in range(4):
  for j in range(4):
    display_matrix.append([j, -i])
display_matrix = np.array(display_matrix) - np.mean(display_matrix, axis=0)
def show(state):
  [plt.text(x, y, str(i), ha='center', va='center', fontsize=16)
   for i, (x, y) in enumerate(state @ display_matrix / 5 + .5)]
show(state)
plt.savefig(sys.output + "/board.png"); plt.clf(); #hide
""" #hide
print(String(take!(buf))) #hide
