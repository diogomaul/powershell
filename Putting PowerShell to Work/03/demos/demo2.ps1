#demo modules
Get-Module
Get-Module -ListAvailable | more
#auto load a module
Get-SmbShare
Get-Module
Get-Module smbshare | Select-Object * | more
#examine where modules are stored
$env:psmodulepath
$env:psmodulepath -split ";"
dir $pshome\modules | more
dir $pshome\modules\SmbShare
#or manually install a module
import-module storage
get-command -module storage
remove-module storage
get-module
cls