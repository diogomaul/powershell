#autoformat
Get-netadapter
#using the alias
Get-netadapter | ft
Get-netadapter | ft -AutoSize
cls

#wrap
get-eventlog application -newest 5
get-eventlog application -newest 5 | ft TimeGenerated,Source,EntryType,Message -Wrap
#alternative
get-eventlog application -newest 5 | Select TimeGenerated,Source,EntryType,Message | ft -Wrap
cls

#continued in Demo2b.ps1