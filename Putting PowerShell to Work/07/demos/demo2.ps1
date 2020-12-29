#demo format-table

help format-table | more
get-alias -definition format-table
cls

dir c:\work\*.dat | format-table -property Fullname,length,lastwritetime
#create custom headings
#or use Select-Object

dir c:\work\*.dat | format-table -property Fullname,Name,
@{Name="Size";Expression={$_.length}},lastwritetime,
@{Name="Age(Days)";Expression = { (Get-Date)-$_.lastwritetime | Select -ExpandProperty TotalDays }}


#grouping
#Get-Vegetable is from PSTeachingTools module (install-module psteachingtools)
get-vegetable | format-table -GroupBy color
#sort first
get-vegetable | sort color | format-table -GroupBy color -Property UPC,Count,Name,IsRoot
cls

dir c:\work -file -recurse | Group Extension | 
Select Count,Name,
@{Name="TotalKB";expression={$_.group | measure length -sum | select -ExpandProperty sum}} |
format-table -group Name -Property Count,TotalKB

cls
#continued in demo2a.ps1
