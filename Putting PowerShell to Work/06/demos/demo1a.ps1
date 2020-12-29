#by property name
help Test-NetConnection -Parameter computername
help Test-NetConnection -Parameter port
cls

import-csv c:\work\computerdata.csv
import-csv c:\work\computerdata.csv | Test-NetConnection

cls
#continued in demo1b.ps1
