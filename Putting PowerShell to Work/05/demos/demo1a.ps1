#demo ForEach enumerator
#typically used more in scripting

$numbers = 1..10

Foreach ($n in $numbers) {
 $max = Get-Random -Minimum 50 -Maximum 500
 $filename = Join-path -Path c:\work -ChildPath "TestFile-$n.txt" 
 Set-Content –value (1..$max) –path $filename
 Get-item $filename
}

#this could have been written using ForEach-Object using $_ instead of $n

#does not write to the pipeline
foreach ($n in $numbers) {$n+3} | sort -Descending
#do this instead
$r = foreach ($n in $numbers) {$n+3}
$r | sort -Descending
#or use foreach-object
$numbers | foreach-object {$_+3} | sort -Descending

cls


