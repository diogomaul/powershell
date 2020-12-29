 
#demo parameter binding

#by value
help restart-service -Parameter name
'bits','winrm' | restart-service -PassThru

help restart-service -Parameter inputobject

get-service winrm | restart-service -PassThru
#advanced stuff here
Trace-Command -name ParameterBinding -Expression { get-service winrm | restart-service } -PSHost

cls
help Test-NetConnection -Parameter computername
get-content c:\work\computers.txt
get-content c:\work\computers.txt | Test-NetConnection -InformationLevel Detailed
cls
#continued in demo1a.ps1