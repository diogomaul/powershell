#demo out-cmdlet

Get-Command -verb out

#you should read help and examples
help Out-File
cls
Get-Service | sort status,Name
Get-Service | sort status,name | out-file c:\work\services.txt
notepad C:\work\services.txt

#this is nice
Get-Service | sort status,name | out-file c:\work\services.txt -NoClobber

#you can also append
Get-Date | out-file c:\work\services.txt -Append
Get-Service | sort status,name | out-file c:\work\services.txt -Append
cls

help Out-GridView
Get-Service | Out-GridView
Get-Service | where status -eq 'running' | Out-GridView -PassThru

Get-Service | where status -eq 'running' | 
Out-GridView -Title "Select services to restart" -PassThru |
foreach { 
Write-Host "Restarting $($_.DisplayName)" -ForegroundColor green
$_ | Restart-Service -PassThru -Force
}

cls
help Out-Printer
Get-Printer
get-eventlog system -Newest 10 -EntryType error | Select TimeGenerated,Source,Message | Out-Printer "Microsoft Print to pdf"
invoke-item c:\work\system.pdf

get-eventlog system -Newest 50 -EntryType error | 
Select TimeGenerated,Source,Message | 
Format-List | 
Out-Printer "Microsoft Print to pdf"

invoke-item c:\work\system.pdf

cls