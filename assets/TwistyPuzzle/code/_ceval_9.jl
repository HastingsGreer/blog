# This file was generated, do not modify it. # hide
py""" #hide
global_perms, global_rotations = DQ_AD_solve(display_matrix)

for i, element in enumerate([1, 12, 4, 9]):
        element = global_perms[element]
        for j in range(frames // 4):
            state = state@expm(1/16 * logm(element))
            show(np.real(state))
            plt.savefig(sys.output + f"/rubiks_rotate{j + 16 * i}.png") #hide
            plt.clf() #hide
collect_gif("rubiks_rotate") #hide
""" #hide
print(String(take!(buf))) #hide
