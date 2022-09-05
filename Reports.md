@def title="Weekly Reports"

@def reeval = true
@def hascode = true
# Weekly Reports


```julia:table
#hideall
reports_paths = readdir("Reports")
months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function key(str)
	
	if !(str[end-1:end] == "md") || str == "todo.md"
		return (9999, 999, 999)
	end	
	month = indexin([str[1:3]], months)[1]
	year = parse(Int, str[6:9])
        day = parse(Int, str[4:5])

	return (-year, -month, -day)
end

sort!(reports_paths, by=key)


for file = reports_paths
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
