#demo format-list
help format-list
get-alias -definition format-list
cls

Get-Vegetable | format-list
#handy way to list all properties
get-vegetable corn | fl *
get-vegetable c* | fl name,count,cookedState
#can create custom properties
get-vegetable c* | fl name,count,@{Name="Status";Expression={$_.cookedstate}}
#can also group
Get-Vegetable | sort color | fl -GroupBy color Name,Count,IsRoot
cls

#views
dir c:\work\*.dat
dir c:\work\*.dat | format-list
dir c:\work\*.dat | format-list -View foo

notepad $pshome\Certificate.format.ps1xml
dir Cert:\LocalMachine\Authroot | format-list -view foo
dir Cert:\LocalMachine\Authroot | format-list -view thumbprintlist
dir Cert:\LocalMachine\Authroot | format-list -view pathonly
dir Cert:\LocalMachine | format-list -view pathonly

cls