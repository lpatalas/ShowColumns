Import-Module "$PSScriptRoot\FormatColumns.dll"

$objs = @(
	@{ Name = 'First' }
	@{ Name = 'Second' }
	@{ Name = 'Third' }
)

Write-Host "By property name:" -ForegroundColor Yellow
$objs | Format-Columns -Property { $_.Name }

Write-Host "By script block:" -ForegroundColor Yellow
$objs | Format-Columns -Property Name