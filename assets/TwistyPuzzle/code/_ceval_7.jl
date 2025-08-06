# This file was generated, do not modify it. # hide
#hideall
py""" #hide
from PIL import Image #hide
def collect_gif(name):
    images = []
    for j in range(frames):
        img = Image.open(sys.output + f"/{name}{j}.png")
        images.append(img)
    # Save as animated GIF
    images[0].save(
        sys.output + f"/{name}_animation.gif",
        save_all=True,
        append_images=images[1:],
        duration=30,  # milliseconds per frame (adjust for speed)
        loop=0,        # 0 = infinite loop
        optimize=True  # reduces file size
    )
collect_gif("all_move")
""" #hide
print(String(take!(buf))) #hide
