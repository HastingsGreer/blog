Recently, I found myself wanting to comment on my friend Brandon's blog. Alas, none of our websites have comments sections!
For this case, I was able to just whack my comment on to his page via a github pull request, but this doesn't scale- among other issues, I had to text him first to get him to 
turn on my ability to make pull requests. Anyways, clearly I need to add a comments section here, and hopefully I can do a good enough job that others in the ring can emulate.

<img width="750" height="1334" alt="IMG_0408" src="https://github.com/user-attachments/assets/aff03d87-9629-4c7f-be4d-8cac30c99e8d" />

The plan for this post is to explore three different commenting systems of increasing jank levels, and see what works in practice!

The first obvious approach is to just mirror a github issue's comments here. This has the advantage of leveraging Microsoft's anti-spam expertise, but at a terrible cost to the whole point
of the indie web revival, which is to divorce from the tech giants. Anyways, the code to do it is just

