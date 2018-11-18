Import-Module "$PSScriptRoot\FormatColumns.dll"

$objs = @(
	@{ Name = 'First'; Group = "Group1" }
	@{ Name = 'Second'; Group = "Group1" }
	@{ Name = 'Third'; Group = "Group2" }
)

Write-Host "By property name:" -ForegroundColor Yellow
$objs | Format-Columns -Property { $_.Name } -GroupBy { $_.Group }

Write-Host "By script block:" -ForegroundColor Yellow
$objs | Format-Columns -Property Name -GroupBy Group