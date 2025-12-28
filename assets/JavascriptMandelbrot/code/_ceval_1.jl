# This file was generated, do not modify it. # hide
run(`sh -c "#hide
curl https://api.github.com/repos/HastingsGreer/blog/issues/4/comments \
| grep -E 'body|login' || echo 'Be the first to comment!'
"`);#hide
