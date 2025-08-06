# This file was generated, do not modify it. # hide
py""" #hide
frames = 64
for j in range(frames):
    for i, element in enumerate(global_perms):
        plt.subplot(2, 2, i + 1)
        show(expm(1/16 * j * logm(element @ move @ element.T)))
    plt.savefig(sys.output + f"/all_move{j}.png") #hide
    plt.clf() #hide
""" #hide
print(String(take!(buf))) #hide
