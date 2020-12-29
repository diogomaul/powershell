New-CimSession -ComputerName localhost
$serverInfo = @{Servername = $computerName}
$serverInfo."OperatingSystem" = Get-CimInstance -ClassName "Win32_OperatingSystem" | Select-Object -ExpandProperty Caption
$Memory = Get-CimInstance -ClassName "Win32_PhysicalMemory" | Select-Object -ExpandProperty Capacity | Measure-Object -Sum
$serverInfo."Memory (GB)" = $Memory.Sum / 1GB
$serverInfo