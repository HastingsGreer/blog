# This file was generated, do not modify it. # hide
#hideall
for file = readdir("Reports")
	if file[end-2:end] == ".md"
		s = ""
		open("Reports/" * file) do f
			s = readline(f)
		end
		println()
		println("[" * file * "](" * file[1:end-3] * ") " * s[12:end])
		println()
	end
end