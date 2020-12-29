#demo jobs
help about_jobs
get-command -noun job
cls

#we'll practice with quick-running commands
#Get-Vegetable is in my teaching module: Install-Module PSTeachingTools
help start-job
start-job -ScriptBlock { Get-Vegetable } | tee -Variable j
#any command will work
$net = start-job {netstat -an}
$net
#using a job name can be easier
start-job {dir $env:temp -file -Recurse | measure length -sum} -Name tempsize

#include parameters
#arguments need to be positional and cannot accept arrays as values

start-job {Param($status) Get-service | where status -eq $status} -Name svc -ArgumentList @('running') 

#run scripts
get-content c:\scripts\dirReport.ps1
#try it out
C:\scripts\DirReport.ps1 c:\scripts
help start-job -Parameter filepath

"c:\work","c:\scripts",$env:temp | foreach {
start-job -FilePath C:\scripts\DirReport.ps1 -Name report -ArgumentList $_
}


#create a job that should fail
start-job {get-content c:\foo.txt | Select-string 'unicorn'} -Name unicorn
start-job {get-foo} -name foo

cls

#CLIP BREAK

#getting jobs
help get-job
cls

get-job
Get-job tempsize
#or with multiple names
get-job report

#by state
Get-job -State Running
Get-job -State Completed
get-job -State failed

#just another object type
get-job | group state

#There is an architecture
get-job tempsize -IncludeChildJob

#CLIP BREAK
#retrieving results
cls
#the non-PowerShell command
$net 
$net | receive-job
$j
receive-job $j
receive-job $j | get-member
$j
#the script results
receive-job tempsize -keep
receive-job tempsize -keep | get-member
#use results
receive-job svc -Keep
receive-job svc -Keep | select -first 3
$r = receive-job report -keep

$r
#clean up the output
$r | sort count -descending | Select * -ExcludeProperty runspaceid | format-table

#get results even if job shows failed.
get-job unicorn
receive-job unicorn -Keep

#CLIP BREAK
cls
#waiting
help wait-job
start-job {1..10 | foreach { $_;sleep -milliseconds 500}} -name n 
get-job n | wait-job
#or do it all at once. You could also sub in Start-Job
get-job n | wait-job | receive-job -Keep

cls

#remove job
help remove-job
Get-Job
remove-job unicorn
remove-job -State Failed
Get-Job
#jobs will be removed when PowerShell ends
#or remove them all
get-job | remove-job
cls