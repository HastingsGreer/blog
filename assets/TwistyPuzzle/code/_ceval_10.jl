# This file was generated, do not modify it. # hide
py""" #hide
try:
    slice_perms, slice_rotations = DQ_AD_solve(display_matrix[:21])
    move = np.eye(54)
    move[:21, :21] = slice_perms[1]

    for j in range(frames):
        for i, element in enumerate([1, 2, 4, 6]):
            element = global_perms[element]
            ax = plt.subplot(2, 2, i + 1, projection="3d")
            ax.set_xlim(-2, 2)
            ax.set_ylim(-2, 2)
            ax.set_zlim(-2, 2)
            show(np.real(expm(1/16 * j * logm(element @ move @ element.T))), ax)
        plt.savefig(sys.output + f"/rubiks_slice_rotate{j}.png") #hide
        plt.clf() #hide
    collect_gif("rubiks_slice_rotate")
except Exception as e:
    print(e)
""" #hide
print(String(take!(buf))) #hide
