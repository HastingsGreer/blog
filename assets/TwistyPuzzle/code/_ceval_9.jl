# This file was generated, do not modify it. # hide
py""" #hide
global_perms, global_rotations = DQ_AD_solve(display_matrix)

for j in range(frames):
    for i, element in enumerate([1, 2, 4, 6]):
        element = global_perms[element]
        ax = plt.subplot(2, 2, i + 1, projection="3d")
        ax.set_xlim(-2, 2)
        ax.set_ylim(-2, 2)
        ax.set_zlim(-2, 2)
        show(np.real(expm(1/16 * j * logm(element))), ax)
    plt.savefig(sys.output + f"/rubiks_rotate{j}.png") #hide
    plt.clf() #hide
collect_gif("rubiks_rotate")
""" #hide
print(String(take!(buf))) #hide
