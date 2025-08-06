# This file was generated, do not modify it. # hide
py""" #hide
try:
    for j in range(4):
        for q in range(16):        
                element = global_perms[j + 3]
                ax = plt.subplot(1, 1, 1, projection="3d")
                ax.set_xlim(-2, 2)
                ax.set_ylim(-2, 2)
                ax.set_zlim(-2, 2)
                
                state = state @ expm(1/16 * logm(element @ move @ element.T))
                show(np.real(state), ax)
                plt.savefig(sys.output + f"/rubiks_sequence{j * 16 + q}.png") #hide
                plt.clf() #hide
    collect_gif("rubiks_sequence")
except Exception as e:
    print(e)
""" #hide
print(String(take!(buf))) #hide
