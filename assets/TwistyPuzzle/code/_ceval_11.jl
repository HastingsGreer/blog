# This file was generated, do not modify it. # hide
py""" #hide
re_order = np.argsort(np.sum(display_matrix, axis=1))

display_matrix = display_matrix[re_order]

colors = colors[re_order]

state = np.eye(54)

global_perms, global_rotations = DQ_AD_solve(display_matrix)

slice_perms, slice_rotations = DQ_AD_solve((display_matrix)[:18])
move = np.eye(54)
move[:18, :18] = slice_perms[1]

for i, element in enumerate([1, 3, 4, 9]):
        element = global_perms[element]
        for j in range(frames // 4):
            state = state@expm(1/16 * logm(element @ move @ element.T))
            show(np.real(state))
            plt.savefig(sys.output + f"/rubiks_corner_rotate{j + 16 * i}.png") #hide
            plt.clf() #hide
collect_gif("rubiks_corner_rotate") #hide
""" #hide
print(String(take!(buf))) #hide
