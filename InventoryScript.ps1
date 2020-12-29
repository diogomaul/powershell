#Inventory Script

#Get OS
$OS= (Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName).caption
$OS

#Disk FreeSpace
