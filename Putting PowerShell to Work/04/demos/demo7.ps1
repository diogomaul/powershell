#demo objects with practical examples

Get-Process
Get-Process lsass | get-member | more
#property sets
Get-Process | Select PSResources
Get-Process | Sort WS -Descending | Select -first 5
Get-Process | Sort WS -Descending | Select -first 5 ID,Name,WS,Handles
cls

help get-eventlog
get-eventlog -LogName system -Newest 10 -EntryType Error
get-eventlog -LogName system -Newest 10 -EntryType Error | Select Time,Source,Message
#use Get-member
get-eventlog -LogName system -Newest 1 | get-member
get-eventlog system -Newest 10 -EntryType Error | Select TimeGenerated,Source,Message
#we'll cover formatting later
get-eventlog system -Newest 10 -EntryType Error | Select TimeGenerated,Source,Message | format-list

cls
get-eventlog system | Group Source 
get-eventlog system | Group Source  -NoElement | Sort Count -Descending | Select -first 10 
get-eventlog system | Group Source  -NoElement | Sort Count -Descending | Select -first 10 | Out-GridView

cls
help get-service
get-service
#what do we have to work with
get-service bits | select *
get-service | where status -eq 'stopped'
#this may not work on older versions of PowerShell
get-service | where status -eq 'stopped' | Select Displayname,Name,StartType
get-service | Where {$_.status -ne 'running' -AND $_.StartType -eq 'Automatic'}
get-service | Where {$_.status -ne 'running' -AND $_.StartType -eq 'Automatic'} | start-service -PassThru

cls
