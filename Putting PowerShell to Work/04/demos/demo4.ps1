#demo Group-Object
help Group-Object
Get-Vegetable | Group-Object -Property color
#a different type of object is written to the pipeline
Get-Vegetable | Group-Object -Property color | Get-Member
Get-Vegetable | Group color | sort count -Descending
Get-Vegetable | Group color | sort count -Descending | select -first 1 -ExpandProperty group
Get-Vegetable | group cookedstate -NoElement

cls