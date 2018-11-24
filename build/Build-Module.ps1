param(
    [ValidatePattern('[a-z]+\d{3}')]
    [String] $PreReleaseVersion,

    [String] $PublishToRepository
)

$workspaceRoot = Split-Path $PSScriptRoot

function Main {
    $modulePath = PublishProjectToOutputDirectory
    CleanupPublishedFiles $modulePath
    GenerateHelpFiles $modulePath
    UpdatePreReleaseVersion $modulePath
    PublishOutputToRepository $modulePath
}

function PublishProjectToOutputDirectory {
    $projectPath = Join-Path $workspaceRoot 'src' 'ShowColumns.csproj'
    $publishOutputPath = Join-Path $workspaceRoot 'build' 'output' 'ShowColumns'
    $sourceManifestPath = Join-Path $workspaceRoot 'src' 'ShowColumns.psd1'
    $manifest = Import-PowerShellDataFile -Path $sourceManifestPath

    Write-Host "Publishing solution '$projectPath' to '$publishOutputPath'" -ForegroundColor Cyan
    Write-Host "Module Version: $($manifest.ModuleVersion)"

    if (Test-Path $publishOutputPath) {
        Write-Host "Removing existing directory: $publishOutputPath"
        Remove-Item $publishOutputPath -Force -Recurse
    }

    dotnet publish `
        --configuration Release `
        --output "$publishOutputPath" `
        /p:ModuleVersion="$moduleVersion" `
        /p:PreserveCompilationContext="false" `
        "$projectPath" `
        | Out-Host

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish exited with error code $LASTEXITCODE"
    }

    return $publishOutputPath
}

function CleanupPublishedFiles($publishDirectory) {
    Write-Host "Cleaning-up directory: $publishDirectory" -ForegroundColor Cyan
    Get-ChildItem (Join-Path $publishDirectory '*.deps.json') `
        | ForEach-Object {
            Write-Host "Removing $_"
            Remove-Item $_.FullName
        }
}

function GenerateHelpFiles($publishDirectory) {
    Write-Host "Generating help files" -ForegroundColor Cyan

    $docsPath = Join-Path $workspaceRoot 'docs'

    New-ExternalHelp -Path $docsPath -OutputPath $publishDirectory -Force `
        | ForEach-Object {
            Write-Host "Generated $($_.FullName)"
        }
}

function UpdatePreReleaseVersion($publishDirectory) {
    if ($PreReleaseVersion) {
        Write-Host "Setting pre-release version to: $PreReleaseVersion" -ForegroundColor Cyan

        $manifestPath = Join-Path $publishDirectory 'ShowColumns.psd1'
        Update-ModuleManifest `
            -Path $manifestPath `
            -Prerelease $PreReleaseVersion
    }
    else {
        Write-Host "Pre-release version was not specified" -ForegroundColor Cyan
    }
}

function PublishOutputToRepository($publishDirectory) {
    if ($PublishToRepository) {
        Write-Host "Publishing to repository '$PublishToRepository'" -ForegroundColor Cyan

        $originalModulePath = $env:PSModulePath
        try {
            $tempModulesPath = Split-Path $publishDirectory
            $env:PSModulePath += ";$tempModulesPath"
            Publish-Module `
                -Path $publishDirectory `
                -Repository $PublishToRepository
        }
        finally {
            $env:PSModulePath = $originalModulePath
        }
    }
    else {
        Write-Host 'Skipping publish because repository name was not specified'  -ForegroundColor Cyan
    }
}

Main
