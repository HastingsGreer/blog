# This file was generated, do not modify it. # hide
py""" #hide
slice_perms, slice_rotations = DQ_AD_solve(display_matrix[:21])
move = np.eye(54)
move[:21, :21] = slice_perms[1]

for i, element in enumerate([1, 3, 4, 9]):
        element = global_perms[element]
        for j in range(frames // 4):
            state = state@expm(1/16 * logm(element @ move @ element.T))
            show(np.real(state))
            plt.savefig(sys.output + f"/rubiks_slice_rotate{j + 16 * i}.png") #hide
            plt.clf() #hide
collect_gif("rubiks_slice_rotate") #hide
""" #hide
print(String(take!(buf))) #hide
