#format-custom
help format-custom
get-alias -definition format-custom
cls

Get-Vegetable | format-custom
get-process powershell | fc
#How did PowerShell know what properties to use?

Get-TypeData -TypeName system.diagnostics.process | select -expand defaultdisplaypropertyset

get-process powershell | fc -Property *

cls

#advanced stuff
dir C:\work\TestData-1.dat | fc -Property fullname,name,length | more
get-content C:\scripts\mycustom.format.ps1xml | more
Update-FormatData -AppendPath C:\scripts\mycustom.format.ps1xml
dir c:\work -file | fc | more

cls