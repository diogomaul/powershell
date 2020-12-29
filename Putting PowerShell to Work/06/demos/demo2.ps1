#demo custom properties
 #create something new

Get-Process | Sort cpu -Descending | 
select -first 10 -property ID,Name,CPU,StartTime,
@{Name="Runtime";Expression={(Get-Date)-$_.starttime}}

cls
#rename
get-service bits -computername win10ent | select *


get-service -computername win10ent | select Displayname,Status,
@{Name="Computername";Expression={$_.machinename}} | Out-GridView -title "Services"

cls

dir -Path c:\work -file -Recurse | Select Name,
@{Name="SizeKB";Expression={[math]::round($_.length/1Kb,2)}},
@{Name="Modified";Expression={$_.lastwritetime}},
@{Name="ModifiedAge";Expression={(Get-Date) - $_.lastwritetime}},
@{Name="Path";Expression={$_.fullname}},
@{Name="Computername";Expression={$env:computername}}

cls