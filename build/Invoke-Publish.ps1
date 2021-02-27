#Requires -PSEdition Core -Module PowerShellGet
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String] $RepositoryName,

    [Parameter(Mandatory, ParameterSetName = "LocalPublish")]
    [switch] $LocalPublish,

    [Parameter(Mandatory, ParameterSetName = "OnlinePublish")]
    [String] $ApiKey
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$workspaceRoot = Split-Path $PSScriptRoot
$modulePath = Join-Path $PSScriptRoot 'output' 'ShowColumns'

if (-not (Test-Path $modulePath)) {
    throw "Path '$modulePath' does not exist"
}

Write-Host "Publishing module '$modulePath' to repository '$RepositoryName'" -ForegroundColor Cyan

$originalModulePath = $env:PSModulePath
try {
    $tempModulesPath = Split-Path $modulePath
    $env:PSModulePath += ";$tempModulesPath"

    if ($LocalPublish) {
        Write-Host 'Running local publish'

        Publish-Module `
            -Path $modulePath `
            -Repository $RepositoryName `
            -ErrorAction Stop

        Write-Host 'Publish succeeded' -ForegroundColor Green
    }
    else {
        Write-Host 'Running Publish-Module ... -WhatIf' -ForegroundColor Cyan
        Publish-Module `
            -Path $modulePath `
            -Repository $RepositoryName `
            -NuGetApiKey $ApiKey `
            -Verbose `
            -WhatIf `
            -ErrorAction Stop

        if ($PSCmdlet.ShouldContinue("Publish module '$modulePath' to repository '$RepositoryName'?", "Confirm Publish")) {
            Publish-Module `
                -Path $modulePath `
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
