#Requires -PSEdition Core -Module PowerShellGet
[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [String] $ModulePath,

    [Parameter(Mandatory)]
    [String] $RepositoryName,

    [Parameter(Mandatory, ParameterSetName = "LocalPublish")]
    [switch] $LocalPublish,

    [Parameter(Mandatory, ParameterSetName = "OnlinePublish")]
    [String] $ApiKey
)

Write-Host "Publishing module '$ModulePath' to repository '$RepositoryName'" -ForegroundColor Cyan

$originalModulePath = $env:PSModulePath
try {
    $tempModulesPath = Split-Path $ModulePath
    $env:PSModulePath += ";$tempModulesPath"

    if ($LocalPublish) {
        Write-Host 'Running local publish'

        Publish-Module `
            -Path $ModulePath `
            -Repository $RepositoryName `
            -ErrorAction Stop

        Write-Host 'Publish succeeded' -ForegroundColor Green
    }
    else {
        Write-Host 'Running Publish-Module ... -WhatIf' -ForegroundColor Cyan
        Publish-Module `
            -Path $ModulePath `
            -Repository $RepositoryName `
            -NuGetApiKey $ApiKey `
            -Verbose `
            -WhatIf `
            -ErrorAction Stop

        if ($PSCmdlet.ShouldContinue("Publish module '$ModulePath' to repository '$RepositoryName'?", "Confirm Publish")) {
            Publish-Module `
                -Path $ModulePath `
                -Repository $RepositoryName `
                -NuGetApiKey $ApiKey `
                -ErrorAction Stop

            Write-Host 'Publish succeeded' -ForegroundColor Green
        }
        else {
            Write-Host 'Publish was cancelled' -ForegroundColor Yellow
        }
    }
}
finally {
    $env:PSModulePath = $originalModulePath
}
