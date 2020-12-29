#Demo object filtering

Get-Vegetable

#look for parameters to limit as early as possible
#like Name, filter, Include, Exclude

help Get-Vegetable
Get-Vegetable corn
Get-Vegetable -RootOnly

help Where-Object
#simple filtering
Get-Vegetable | where-object -property color -eq yellow
#legacy
Get-Vegetable | where {$_.color -eq 'yellow' }
#you may also see this
Get-Vegetable | where {$psitem.color -eq 'yellow' }

#filtering depends on comparison
help about_Comparison_Operators
cls
1 -eq 1
1 -lt 5
1 -gt 5
#not case sensitive
'jeff' -eq 'Jeff'
'jeff' -ceq 'Jeff'
'jeff' -like 'je*'
'jeff' -notlike 'je*'
#match uses regular expressions
'jeff' -match "^J"
'srv03' -match "\w+\d{1,3}"

cls

Get-Vegetable | where count -gt 10

#compound filters
Get-Vegetable | where count -gt 10 -and color -eq green
Get-Vegetable | where {$_.count -gt 10 -and $_.color -eq 'green'} | sort count -Descending
Get-Vegetable | where {$_.IsRoot -OR $_.color -eq 'green'} | select name,color,isroot
Get-Vegetable | where {$_.isroot -eq $False} | Select name,isroot

#this is better PowerShell
Get-Vegetable | where {-Not ($_.isroot)} | Select name,isroot

#filter as far left as possible
measure-command {dir C:\windows\System32 -recurse | where { $_.Extension -eq '.exe'}}
measure-command {dir C:\windows\System32 -recurse -filter *.exe }

cls