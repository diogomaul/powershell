#demo objects
#some demo tools to use
find-module psteachingtools
install-module psteachingtools

#cmdlets have verb-noun naming convention.
get-command -noun vegetable
cls

#typical output
help Get-Vegetable
Get-Vegetable

#using Get-Member
help Get-Member
Get-Vegetable | Get-Member
Get-Vegetable | Get-Member -MemberType Properties
#notice that default output names may not match actual property names

Get-Vegetable | Get-Member -MemberType Method
help set-vegetable

cls