#demo property expansion

#let's keep it simple
#install-module psteachingtools

Get-Vegetable
Get-Vegetable | Select Name -Unique
Get-Vegetable | Select Name -Unique | out-file c:\work\veglist.txt
notepad C:\work\veglist.txt

cls
Get-Vegetable | Select -expandproperty Name -Unique
Get-Vegetable | Select -expandproperty Name -Unique | out-file c:\work\veglist.txt
notepad C:\work\veglist.txt

cls
#use with parameter binding
help Get-Vegetable -Parameter name
get-content c:\work\veglist.txt | Where {$_ -like "c*"} | Get-Vegetable

cls

#advanced techniques
(get-vegetable).name
(get-service | where status -eq running).DisplayName | Sort | more

cls