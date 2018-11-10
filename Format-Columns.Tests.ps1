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

function Generate-Files($directoryPath, $count = 3, $prefix = '') {
    1..$count | %{ Create-File (Join-Path $directoryPath "$prefix$_.txt") }
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

    Create-Directory "$TestsDir\Columns"
    Generate-Files "$TestsDir\Columns" -count 100 -prefix test

    $consoleWidth = $Host.UI.RawUI.BufferSize.Width
    $leftLength = [Math]::Floor(($consoleWidth - 1) / 2)
    $rightLength = $consoleWidth - $leftLength - 1

    Create-Directory "$TestsDir\FitWidth"
    Create-File (Join-Path "$TestsDir\FitWidth" ('a' * $leftLength))
    Create-File (Join-Path "$TestsDir\FitWidth" ('b' * $leftLength))
    Create-File (Join-Path "$TestsDir\FitWidth" ('c' * $rightLength))
    Create-File (Join-Path "$TestsDir\FitWidth" ('d' * $rightLength))
}

function Test($description, $script) {
    Write-Host "--- Testing $description" -ForegroundColor DarkYellow
    $measurements = Measure-Command { $script.Invoke() }
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

Test 'organizing items into multiple columns' {
    Get-ChildItem "$TestsDir\Columns" | Format-Columns
}

Test 'listing folder contents non-recursively in reverse order' {
    Get-ChildItem "$TestsDir\Subfolders" | Sort-Object -Descending | Format-Columns
}

Test 'listing folder contents recursively' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse | Format-Columns
}

Test 'listing folder contents recursively grouped by directory' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Format-Columns -GroupBy PSParentPath
}

Test 'listing folder contents recursively, sorted in descending order and grouped by directory' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Sort-Object Name -Descending `
        | Format-Columns -GroupBy PSParentPath
}

Test 'displaying items fitting console width exactly' {
    Get-ChildItem "$TestsDir\FitWidth" | Format-Columns
}

Test 'displaying custom items grouped by arbitrary property' {
    function NewItem($name, $groupName) {
        return [PSCustomObject] @{
            PSChildName = $name
            GroupName = $groupName
        }
    }

    $items = @(
        NewItem 'First' 'Group1'
        NewItem 'Second' 'Group2'
        NewItem 'Third' 'Group1'
        NewItem 'Fourth' 'Group2'
        NewItem 'Fifth' 'Group3'
        NewItem 'Sixth' 'Group3'
        NewItem 'Seventh' 'Group1'
        NewItem 'Eighth' 'Group2'
        NewItem 'Ninth' 'Group1'
        NewItem 'Tenth' 'Group2'
        NewItem 'Eleventh' 'Group3'
        NewItem 'Twelveth' 'Group3'
    )

    $items | Format-Columns -GroupBy GroupName
}