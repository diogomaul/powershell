#demo Sort-object
help Sort-Object
Get-Vegetable | Sort Count
Get-Vegetable | Sort Count -Descending
Get-Vegetable | Sort Count -Descending | Select Count,Name
Get-Vegetable | sort color -Unique

#some sorts are based on enums
#this is slightly advanced stuff
Get-Vegetable | Select Name,Color,@{Name="ColorValue";Expression={$_.color.value__}} | sort Color
Get-Vegetable | sort {$_.color.tostring()} -Unique

cls