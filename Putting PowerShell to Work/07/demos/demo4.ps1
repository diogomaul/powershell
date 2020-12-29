#demo format-wide
help format-wide
get-alias -definition format-wide
cls

get-vegetable | format-wide
get-vegetable | format-wide -Column 4
get-vegetable | format-wide -AutoSize
get-service | fw -column 3

#specify a property
get-service | fw Displayname -AutoSize
dir c:\windows -Directory | fw -AutoSize
cls

#grouping
dir c:\work -file | sort extension | fw -GroupBy extension -AutoSize
#grouping by object type - directories and files
dir c:\work | sort {$_.GetType().Name} | fw -GroupBy {$_.GetType().Name} -AutoSize

cls

