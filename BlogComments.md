
@def title = "Blog Comment Sections"
@def hascode = true
@def rss = "Blog Comment Sections"
@def rss_title = "Blog Comment Sections"
@def rss_pubdate = Date(2025, 12, 8)

Blog Comment Sections
====================


Recently, I found myself wanting to comment on my friend [Brandon's blog](https://subdavis.com/posts/2025-12-navidrome-bandcamp/). Alas, none of our websites have comments sections!
For this case, I was able to just whack my comment on to his page via a github pull request, but this doesn't scale- among other issues, I had to text him first to get him to 
turn on my ability to make pull requests. 

\fig{screenshot}

Anyways, clearly I need to add a comments section here, and hopefully I can do a good enough job that others in the webring can emulate.

The plan for this post is to explore three different commenting systems of increasing jank levels, and see what works in practice!

The first obvious approach is to just mirror a github issue's comments here. This has the advantage of leveraging Microsoft's anti-spam expertise, but at a terrible cost to the whole point
of the indie web revival, which is to divorce from the tech giants. The plan is to build out a whole backend / js / html / css stack to implement this feature. As a first step, let's explore the github api using curl.

```!
using PyCall #hide
buf = IOBuffer(); #hide
pyimport("sys").stdout = buf; #hide
pyimport("sys").output = @OUTPUT #hide
py""" #hide
import os #hide
os.system(''' #hide
curl https://api.github.com/repos/HastingsGreer/blog/issues/2/comments \
 | grep -e "body\|login"
''') #hide
""" #hide
print(String(take!(buf))) #hide
```

Wait lmao this ssg embeds the outputs of code snippets. Screw other methods, comment section finished.

To comment on this post, just comment on this issue, and it should appear above sooner or later (a few minutes?). Gotta add rebuilds of the webpage on issue triggers, hope this doesn't go viral on hacker news.

[https://github.com/HastingsGreer/blog/issues/2](https://github.com/HastingsGreer/blog/issues/2)


```
name: Build and Deploy
on:
  push:
    branches:
      - main
      - master
  issue_comment: 
      types: [created, edited, deleted]
```
yeah that seems fine.
