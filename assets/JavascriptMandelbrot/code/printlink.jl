# This file was generated, do not modify it. # hide
#hideall
comment_num = 4
println("`", "``!")
println("run(`sh -c \"#hide")
println("curl https://api.github.com/repos/HastingsGreer/blog/issues/$comment_num/comments \\")
println("| grep -E 'body|login' || echo 'Be the first to comment!'")
println("\"`);#hide")
println("`", "``")
println("\n\n[Leave your comment on this github issue](https://github.com/HastingsGreer/blog/issues/", comment_num, ")")