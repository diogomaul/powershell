#demo foreach-object

help ForEach-Object

cls
#get a list of numbers
1..10
#concept demonstration
1..10 | foreach-object -process {$_ * 2}
#this is the typical way you would type it
1..10 | foreach  {$_ * 2}

#alternative
1..10 | foreach {$PSItem *2}
cls

#using my sample commands -> install-module psteachingtools

Get-Vegetable | Get-Member
Get-Vegetable -RootOnly | Select Name,IsPeeled
Get-Vegetable -RootOnly | foreach {$_.peel() ; get-vegetable $_.name | Select name,ispeeled}
Get-Vegetable | foreach { Export-Clixml -InputObject $_ -path "$($_.name).xml" }
dir *.xml

cls

#real cmdlet
dir c:\work -file -Recurse | where {$_.length -ge 500 -AND $_.extension -notmatch ".zip|.exe"}

dir c:\work -file -Recurse | 
where {$_.length -ge 500 -AND $_.extension -notmatch ".zip|.exe"} | Foreach { 
$file = Join-Path -path $_.Directory -ChildPath "$($_.BaseName).zip"
Compress-Archive -path $_.fullname -DestinationPath $file -CompressionLevel Optimal -Force
}


dir c:\work\*.zip -Recurse

#demo the different scriptblocks

dir c:\work -Directory | 
foreach -begin { $h=@{} ; $results=@() } -process { 
$stat = dir $_.FullName -file -Recurse | Measure-Object -Property length -sum
$h.Path = $_.fullname
$h.Files = $stat.count
$h.TotalSize = $stat.sum
$results+=[pscustomobject]$h
} -end { 
$results 
}

cls

#don't do this even though you technically can
get-service | get-member -MemberType Methods

#no support for -WhatIf or confirm
get-service lanmanworkstation,winmgmt,vmicvss | foreach { $_.Pause()}

#verify it worked
get-service lanmanworkstation,winmgmt,vmicvss

#look for cmdlets
get-command -noun service
get-service lanmanworkstation,winmgmt,vmicvss | resume-service -PassThru

cls

