$CurrentDir = (Split-Path $MyInvocation.MyCommand.Definition)
$TestsDir = (Join-Path $CurrentDir 'TestData')

. "$CurrentDir\Format-Columns.ps1"

function Clear-Directory($path) {
    Remove-Item (Join-Path $path '*') -Force -Recurse
}

function Create-Directory($path) {
    New-Item $path -ItemType Directory | Out-Null
}

function Create-File($path) {
    New-Item $path -ItemType File | Out-Null
}

function Generate-Files($directoryPath, $count = 3) {
    1..$count | %{ Create-File (Join-Path $directoryPath "$_.txt") }
}

function Prepare-TestData {
    if (-not (Test-Path $TestsDir)) {
        Create-Directory $TestsDir
    }

    Clear-Directory $TestsDir
    Create-Directory "$TestsDir\Empty"
    Create-Directory "$TestsDir\Subfolders"
    Generate-Files "$TestsDir\Subfolders"

    foreach ($folderNumber in 1..3) {
        Create-Directory "$TestsDir\Subfolders\$folderNumber"
        Generate-Files "$TestsDir\Subfolders\$folderNumber"
    }
}

function Test($description, $script) {
    Write-Host "--- Testing $description" -ForegroundColor DarkYellow
    $measurements = Measure-Command { $script.Invoke() | Out-Default }
    Write-Host "--- Total time $($measurements.TotalMilliseconds) msec" -ForegroundColor DarkYellow
    Write-Host
}

Prepare-TestData

Test 'empty directory' {
    Get-ChildItem "$TestsDir\Empty" | Format-Columns
}

Test 'listing folder contents non-recursively' {
    Get-ChildItem "$TestsDir\Subfolders" | Format-Columns
}

Test 'listing folder contents non-recursively in reverse order' {
    Get-ChildItem "$TestsDir\Subfolders" | Sort-Object -Descending | Format-Columns
}

Test 'listing folder contents recursively' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse | Format-Columns
}

Test 'listing folder contents recursively grouped by directory' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse | Format-Columns -GroupByDirectory
}

Test 'listing folder contents recursively, sorted in descending order and grouped by directory' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse | Sort-Object -Descending | Format-Columns -GroupByDirectory
}