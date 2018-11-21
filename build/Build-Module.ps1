param(
    [ValidatePattern('[a-z]+\d{3}')]
    [String] $PreReleaseVersion,

    [String] $PublishToRepository
)


$workspaceRoot = Convert-Path (git rev-parse --show-toplevel)
$scriptsRoot = Join-Path $workspaceRoot 'scripts'
$projectPath = Join-Path $workspaceRoot 'src' 'ShowColumns' 'ShowColumns.csproj'
$publishOutputPath = Join-Path $workspaceRoot 'build' 'output' 'publish'
$modulesRootPath = Join-Path $workspaceRoot 'build' 'output' 'modules'
$moduleOutputPath = Join-Path $modulesRootPath 'ShowColumns'
$manifestPath = Join-Path $scriptsRoot 'ShowColumns.psd1'
$manifest = Get-Content $manifestPath -Raw | Invoke-Expression
$moduleVersion = $manifest.ModuleVersion

Write-Host "Publishing solution '$projectPath' to '$publishOutputPath'" -ForegroundColor Yellow
Write-Host "Version: $moduleVersion"

dotnet publish `
    --configuration Release `
    --output "$publishOutputPath" `
    /p:ModuleVersion="$moduleVersion" `
    "$projectPath"

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
    Get-ChildItem $publishOutputPath -Filter '*.dll'
    Get-ChildItem $scriptsRoot
)

$packageFiles | ForEach-Object {
    Write-Host "Copying $_"
    Copy-Item `
        -Path $_.FullName `
        -Destination $moduleOutputPath `
        -Container `
        -Recurse `
        -ErrorAction Stop
}

if ($PreReleaseVersion) {
    Write-Host "Setting pre-release version to '$PreReleaseVersion'"

    $publishedManifestPath = Join-Path $moduleOutputPath 'ShowColumns.psd1'
    Update-ModuleManifest `
        -Path $publishedManifestPath `
        -Prerelease $PreReleaseVersion
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