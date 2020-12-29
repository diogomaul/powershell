#show version
$psversiontable

#demo snapins
Get-PSSnapin
Get-PSSnapin -Registered
Add-PSSnapin quest*
Get-PSSnapin
Get-Command -Module quest* | more
help get-qaduser
get-pssnapin quest* | Select-Object *
#snapins can be manually removed
Remove-PSSnapin quest*
help get-qaduser

cls

