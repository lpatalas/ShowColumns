#Requires -PSEdition Core -Module platyPS, PSScriptAnalyzer
[CmdletBinding()]
param(
    [ValidateRange('Positive')]
    [Nullable[Int32]] $PreReleaseNumber
)

$workspaceRoot = Split-Path $PSScriptRoot

function Main {
    $modulePath = PublishProjectToOutputDirectory
    CleanupPublishedFiles $modulePath
    GenerateHelpFiles $modulePath
    UpdatePreReleaseVersion $modulePath
    RunPSScriptAnalyzer $modulePath
    Write-Host 'Build succeeded' -ForegroundColor Green

    Get-Item $modulePath
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
    if ($PreReleaseNumber) {
        $preReleaseVersion = 'pre{0:000}' -f $PreReleaseNumber
        Write-Host "Setting pre-release version to: $preReleaseVersion" -ForegroundColor Cyan

        $manifestPath = Join-Path $publishDirectory 'ShowColumns.psd1'
        Update-ModuleManifest `
            -Path $manifestPath `
            -Prerelease $preReleaseVersion
    }
    else {
        Write-Host "Pre-release version was not specified" -ForegroundColor Cyan
    }
}

function RunPSScriptAnalyzer($publishDirectory) {
    Write-Host 'Running PSScriptAnalyzer on published project' -ForegroundColor Cyan

    if (-not (Get-Module PSScriptAnalyzer -ErrorAction SilentlyContinue)) {
        Write-Host 'Importing PSScriptAnalyzer module'
        Import-Module PSScriptAnalyzer -ErrorAction Stop
    }

    $allResults = @()

    Get-ChildItem -Path $publishDirectory -Filter '*.ps*1' `
        | ForEach-Object {
            Write-Host "Analyzing $($_.FullName)"
            $results = Invoke-ScriptAnalyzer `
                -Path $_ `
                -Severity Warning `
                -Settings PSGallery

            $allResults += @($results)
        }

    if ($allResults.Count -gt 0) {
        $allResults | Out-Host
        throw 'PSScriptAnalyzer returned some errors'
    }
}

Main
