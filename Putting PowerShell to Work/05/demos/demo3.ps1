#put a lot of this together

#select system and application
$logs = Get-Eventlog -list | Select LogDisplayName | 
Out-Gridview -Title "Select one or more logs" -OutputMode Multiple

$count = 1,10,25,50 | Out-GridView -Title "How many entries?" -OutputMode Single
$printer = Get-Printer | Select Name | Out-GridView -Title "Select a printer" -OutputMode Single

$logs | foreach {
$_.LogDisplayName
Get-Eventlog -LogName $_.LogDisplayName -Newest $count -EntryType Error |
Select TimeGenerated,Source,Message | Format-List | 
Out-Printer $printer.Name
}

cls

