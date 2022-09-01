@def title="Weekly Reports"

@def reeval = true
@def hascode = true
# Weekly Reports


```julia:table
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
	
```

\textoutput{table}
