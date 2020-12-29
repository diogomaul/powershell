#demo invoke-command and Get-Wmiobject

help invoke-command -Parameter asjob
cls
#often used with remote commands
#use local name as a remote
hostname
invoke-command -ScriptBlock { get-eventlog -list | where {$_.entries.count -gt 0}} -ComputerName win10ent -AsJob
get-job | wait-job | receive-job -Keep

#this too can run scripts
$t = invoke-command -FilePath C:\scripts\DirReport.ps1 -ArgumentList C:\Windows\Temp -ComputerName win10ent -AsJob
get-job
receive-job $t

$a = invoke-command -ScriptBlock {param([string]$svc) get-service $svc } -ComputerName win10ent,foo,bar -AsJob -ArgumentList 'bits'
$a
$a | get-job -IncludeChildJob
#receive results anyway
$a | receive-job -Keep
#learn more
help about_remote_jobs
cls

#CLIP BREAK
#We don't cover WMI in this course
help get-wmiobject -param asjob
cls
get-wmiobject -class win32_process -asjob
get-job -Newest 1
#using with remote computers is the real reason
$b = get-wmiobject win32_service -ComputerName win10ent,foo -AsJob
$b | wait-job | receive-job -Keep | select -last 5 | format-table
#not available with Get-CimInstance
start-job { get-ciminstance win32_volume -computername win10ent,foo} -Name voljob
wait-job voljob | receive-job -keep
cls

