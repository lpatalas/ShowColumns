$workspaceRoot = Convert-Path (git rev-parse --show-toplevel)
$solutionPath = Join-Path $workspaceRoot 'src' 'ShowColumns.sln'
$publishOutputPath = Join-Path $workspaceRoot 'build' 'output' 'publish'
$moduleOutputPath = Join-Path $workspaceRoot 'build' 'output' 'ShowColumns'

Write-Host "Publishing solution '$solutionPath' to '$publishOutputPath'" -ForegroundColor Yellow

dotnet publish `
    --configuration Release `
    --output "$publishOutputPath" `
    "$solutionPath"

if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish exited with error code $LASTEXITCODE"
}

Write-Host "Copying package contents to '$moduleOutputPath'" -ForegroundColor Yellow

if (Test-Path $moduleOutputPath) {
    Remove-Item `
        -Path $moduleOutputPath `
        -Force `
        -Recurse `
        -ErrorAction Stop
}

New-Item `
    -Path $moduleOutputPath `
    -ItemType Directory `
    -ErrorAction Stop `
    | Out-Null

$packageFiles = @(
    Join-Path $publishOutputPath 'ShowColumns.dll'
    Join-Path $workspaceRoot 'ShowColumns.psd1'
)

$packageFiles | ForEach-Object {
    Write-Host "Copying $_"
    Copy-Item `
        -Path $_ `
        -Destination $moduleOutputPath `
        -Container `
        -ErrorAction Stop
}