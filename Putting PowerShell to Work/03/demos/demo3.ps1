
#demo PowerShellGet
Get-command -module PowerShellGet | more
Get-PSRepository
help find-module
Find-Module -tag sqlserver
find-module sqlserver | Select-Object *
install-module sqlserver
get-module sqlserver -ListAvailable
get-command -module sqlserver | more
help Backup-SqlDatabase
cls
get-command -noun module
save-module sqlhelper -Path c:\save
dir c:\save -recurse | more
ise C:\save\SQLHelper\1.1.0.3\SQLHelper.psm1
#you could install the module again from the PSGallery
#or copy/move it
move -Path C:\save\sqlhelper -Destination 'C:\Program Files\windowspowershell\modules'
get-module sqlhelper -ListAvailable
get-command -Module sqlhelper

cls

