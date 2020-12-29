New-CimSession -ComputerName localhost
Get-CimInstance -ClassName "Win32_OperatingSystem" | Select-Object Caption