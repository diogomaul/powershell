#Views
#search for system.diagnostics.process
set-clipboard system.diagnostics.process
notepad $pshome\DotNetTypes.format.ps1xml

get-process -IncludeUserName
get-process | format-table -view priority
#PowerShell will tell you valid values on error
get-process | format-table -view foo
get-process | format-table -view starttime
#this is probably the better way to use this view
get-process | sort starttime | format-table -view starttime

cls
#try with different cmdlets
get-service | format-table -view foo
get-service | format-table -view service
cls

#Format right
#this will fail
Get-Vegetable | format-table Name,Color,IsRoot | sort color
get-vegetable | get-member
get-vegetable | format-table | get-member
#correct
Get-Vegetable | sort color | format-table Name,Color,IsRoot
#exception
Get-Vegetable | sort color | format-table Name,Color,IsRoot | out-file c:\work\v.txt
get-content c:\work\v.txt
#exception to the exception
Get-Vegetable | sort color | format-table Name,Color,IsRoot | out-gridview
#do this instead
Get-Vegetable | select Name,Color,IsRoot | out-gridview

cls