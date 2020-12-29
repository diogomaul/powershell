$limit = (Get-Date).AddMinutes(-20)
$path = "D:\MobiControl\GOM"
$Extension = "*.json"
Get-ChildItem -Path $path -Filter $Extension -Force -Recurse | Where-Object {$_.CreationTime -lt $limit} | Remove-Item