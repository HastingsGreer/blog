# This file was generated, do not modify it. # hide
#hideall
for file = readdir("_assets/ICON_test")
	if file[end-3:end] == ".png"
		println()
		println("\\fig{/assets/ICON_test/" * file * "}" )
		println(file)
	end
end