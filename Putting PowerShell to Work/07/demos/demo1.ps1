#demo formatting basics
get-service bits

#or pipe to Get-Member to discover type name
get-service | get-member name
dir $pshome\DotNetTypes.format.ps1xml

#search for System.ServiceProcess.ServiceController
#notepad $pshome\DotNetTypes.format.ps1xml

get-content $pshome\DotNetTypes.format.ps1xml | 
Select-String system.serviceprocess.servicecontroller -Context 0,30 | more

get-service bits | format-table
get-service bits | format-list
cls
#demo object types without definitions
import-csv C:\work\computerdata.csv | get-member -MemberType Properties
import-csv C:\work\computerdata.csv

#a different file with 6 properties
import-csv C:\work\computerdata2.csv
#but I can override
import-csv C:\work\computerdata2.csv | format-table
cls


