@def title="Weekly Reports"

@def reeval = true
@def hascode = true
# Weekly Reports


```julia:table
#hideall
for file = readdir("Reports")
	if file[end-2:end] == ".md"
		println()
		println("[" * file * "](" * file[1:end-3] * ")")
		println()
	end
end
	
```

\textoutput{table}
