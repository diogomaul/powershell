[cmdletbinding()]
Param(
[Parameter(Position=0)]
[string]$Path="."
)

#resolve path name to a complete name
$dir = Convert-Path $path
if (Test-Path $dir) {
    Get-Childitem -Path $dir -file -Recurse | 
    Measure-Object length -sum -Average |
    Select-Object -property @{Name="Path";Expression={$dir}},Count,
    @{Name="SumKB";Expression={[math]::Round($_.sum/1kb,4)}},
    @{Name="AvgKB";Expression={[math]::Round($_.average/1kb,4)}}
}
else {
    Write-Warning "Can't find $dir"
}
