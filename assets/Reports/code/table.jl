# This file was generated, do not modify it. # hide
#hideall
for file = readdir("Reports")
	if file[end-2:end] == ".md"
		println()
		println("[" * file * "](" * file[1:end-3] * ")")
		println()
	end
end