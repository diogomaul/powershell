#demo Select-Object

Get-Vegetable
help Select-Object
Get-Vegetable | Select -property Name
Get-Vegetable | Select Name,Count,State
#need to use actual property name
Get-Vegetable | Get-Member
#can also use properties not displayed by default
Get-Vegetable | Select Name,Count,CookedState,IsRoot
#can use wildcards
Get-Vegetable | Select Name,C*

Get-Vegetable -RootOnly | Select -First 1
Get-Vegetable  | Select -First 1 -Property *
Get-Vegetable | Select Name -Unique
Get-Vegetable | Select -Unique -ExpandProperty Name

cls
