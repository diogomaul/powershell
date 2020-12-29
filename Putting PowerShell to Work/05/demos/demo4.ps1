#bonus content

help Tee-object
cls

get-process | sort WS -descending | Select -first 10 | Tee-Object -FilePath c:\work\proc.txt

get-content c:\work\proc.txt
cls

#also means I could do this

#using default printer
get-process | sort WS -descending | Select -first 10 | Tee-Object -FilePath c:\work\proc.txt | Out-Printer

invoke-item c:\work\proc.pdf

cls