#pull it all together

#leverage parameter binding
Get-NetIPAddress | more
Get-NetAdapter

help Get-NetIPAddress -param interface*
Get-NetAdapter | Select interface*

Get-NetAdapter | Get-NetIPAddress -AddressFamily IPv4

cls

#focus on the process I'm using, not the result
#this is something you'd most likely put in a script

get-eventlog application -EntryType Error,Warning | Group Source | foreach {
$file = Join-Path -path C:\work -ChildPath "$($_.name).txt"
"$($_.count) entries" | Out-File -FilePath $file
$_.group | foreach {
 $_ | Select TimeGenerated,EntryType | Out-File -FilePath $file -Append
 $_ | Select -ExpandProperty Message | Out-File -FilePath $file -Append
}
Get-Item $file
}

notepad 'C:\work\Application Error.txt'

cls
