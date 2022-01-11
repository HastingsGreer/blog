

@def title = "ICON_test"
@def hascode = true
@def rss = "An exploration of inverse consistency for driving image registration"
@def rss_title = "blaaaaa"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]
@def reeval = true

```julia:table
#hideall
for file = readdir("_assets/ICON_test")
	if file[end-3:end] == ".png"
		println()
		println(file)
		println()
		println("\\fig{/assets/ICON_test/" * file * "}" )
	end
end
	
```


\textoutput{table}


