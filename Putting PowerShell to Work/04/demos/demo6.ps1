#Demo Measure-Object

#try all my demos with cmdlets like Get-Service or Get-Process
help Measure-Object
Get-Vegetable -RootOnly | Measure-Object -Property count -Sum
Get-Vegetable -RootOnly | Measure count -sum | get-member
Get-Vegetable -RootOnly | Measure count -sum | Select -ExpandProperty sum

cls

#a real world example
dir C:\windows\notepad.exe | select *
dir c:\windows\*.exe | measure length -Sum -Average -Maximum -Minimum
cls
get-process | get-member -MemberType Properties | more
#you can measure multiple properties
get-process | measure workingset,peakworkingset -Sum -Average

cls