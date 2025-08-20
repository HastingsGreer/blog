# This file was generated, do not modify it. # hide
py""" #hide
import itertools
colors = []
display_matrix = []
for sticker in itertools.product(* [range(5)] * 3):
    sticker = np.array(sticker)
    if np.sum(sticker == 0) + np.sum(sticker == 4) == 1:
        colors.append(.5 + .5 * (0 - (sticker == 0) + (sticker == 4)))
        display_matrix.append(sticker)

display_matrix = np.array(display_matrix) - np.mean(np.array(display_matrix), axis=0, keepdims=True)
colors = np.array(colors)

state = np.eye(54)

def show(state):
    locations = state @ display_matrix
    fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_zlim(-2, 2)
    ax.scatter(locations[:, 0], locations[:, 1], locations[:, 2], c=colors, s=800, alpha=1)
show(state)
plt.savefig(sys.output + "/rubiks.png") #hide
plt.clf() #hide
""" #hide
print(String(take!(buf))) #hide
