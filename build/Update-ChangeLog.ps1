#Requires -PSEdition Core
$workspaceRoot = Split-Path $PSScriptRoot
$changeLogPath = Join-Path $workspaceRoot 'CHANGELOG.md'
$releaseNotesPath = Join-Path $workspaceRoot 'docs\release-notes\*.md'

'# Change Log' | Set-Content $changeLogPath -Encoding UTF8

Get-ChildItem -Path $releaseNotesPath `
    | Sort-Object `
        -Descending `
        -Property @{
            Expression = {
                $_.Name -match '(\d+)\.(\d+)\.(\d+)\.md' | Out-Null
                '{0:000}.{1:000}.{2:000}' -f $matches[1], $matches[2], $matches[3]
            }
        } `
    | ForEach-Object {
        '' | Add-Content $changeLogPath -Encoding UTF8
        $_ | Get-Content | Add-Content $changeLogPath -Encoding UTF8
    }
