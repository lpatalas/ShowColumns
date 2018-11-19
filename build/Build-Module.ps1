param(
    [String] $PublishToRepository
)

$workspaceRoot = Convert-Path (git rev-parse --show-toplevel)
$scriptsRoot = Join-Path $workspaceRoot 'scripts'
$solutionPath = Join-Path $workspaceRoot 'src' 'ShowColumns.sln'
$publishOutputPath = Join-Path $workspaceRoot 'build' 'output' 'publish'
$modulesRootPath = Join-Path $workspaceRoot 'build' 'output' 'modules'
$moduleOutputPath = Join-Path $modulesRootPath 'ShowColumns'
$manifestPath = Join-Path $scriptsRoot 'ShowColumns.psd1'
$manifest = Get-Content $manifestPath -Raw | Invoke-Expression
$moduleVersion = $manifest.ModuleVersion

Write-Host "Publishing solution '$solutionPath' to '$publishOutputPath'" -ForegroundColor Yellow
Write-Host "Version: $moduleVersion"

dotnet publish `
    --configuration Release `
    --output "$publishOutputPath" `
    /p:ModuleVersion="$moduleVersion" `
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
    (Get-ChildItem $scriptsRoot | ForEach-Object FullName)
)

$packageFiles | ForEach-Object {
    Write-Host "Copying $_"
    Copy-Item `
        -Path $_ `
        -Destination $moduleOutputPath `
        -Container `
        -Recurse `
        -ErrorAction Stop
}

if ($PublishToRepository) {
    Write-Host "Publishing to repository '$PublishToRepository'" -ForegroundColor Yellow

    $originalModulePath = $env:PSModulePath
    try {
        $env:PSModulePath += ";$modulesRootPath"
        Publish-Module `
            -Path $moduleOutputPath `
            -Repository $PublishToRepository
    }
    finally {
        $env:PSModulePath = $originalModulePath
    }
}