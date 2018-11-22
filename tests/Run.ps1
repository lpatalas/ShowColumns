Import-Module "$PSScriptRoot\ShowColumns.dll"

$CurrentDir = (Split-Path $MyInvocation.MyCommand.Definition)
$TestsDir = (Join-Path $CurrentDir 'TestData')

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
    Get-ChildItem "$TestsDir\Empty" | Show-Columns -Property Name
}

Test 'listing folder contents non-recursively' {
    Get-ChildItem "$TestsDir\Subfolders" | Show-Columns -Property Name
}

Test 'organizing items into multiple columns' {
    Get-ChildItem "$TestsDir\Columns" | Show-Columns -Property Name
}

Test 'listing folder contents non-recursively in reverse order' {
    Get-ChildItem "$TestsDir\Subfolders" | Sort-Object -Descending | Show-Columns -Property Name
}

Test 'listing objects longer than console window width' {
    @{ Name = 'a' * ($Host.UI.RawUI.BufferSize.Width + 10) } `
        | Show-Columns -Property Name
}

Test 'listing folder contents recursively' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse | Show-Columns -Property Name
}

Test 'listing folder contents recursively grouped by directory' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Show-Columns -Property Name -GroupBy { Convert-Path $_.PSParentPath }
}

Test 'listing folder contents recursively, sorted in descending order and grouped by directory' {
    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Sort-Object Name -Descending `
        | Show-Columns -Property Name -GroupBy { Convert-Path $_.PSParentPath }
}

Test 'displaying items fitting console width exactly' {
    Get-ChildItem "$TestsDir\FitWidth" | Show-Columns -Property Name
}

Test 'displaying long items with explicit minimum column count' {
    $items = @(
        @{ Name = ('a' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('b' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('c' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('d' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('e' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('f' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('g' * $Host.UI.RawUI.BufferSize.Width) }
        @{ Name = ('h' * $Host.UI.RawUI.BufferSize.Width) }
    )

    $items | Show-Columns -Property Name -MinimumColumnCount 3
}

Test 'custom colors' {
    $itemStyleSelector = {
        switch -regex ($_.Name) {
            '1' { [ConsoleColor]::Red }
            '2' { [ConsoleColor]::Blue }
            '3' { [ConsoleColor]::Green }
        }
    }

    $groupStyleSelector = {
        switch -regex ($_) {
            '1$' { [ConsoleColor]::Red }
            '2$' { [ConsoleColor]::Blue }
            '3$' { [ConsoleColor]::Green }
        }
    }

    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Show-Columns `
            -Property Name `
            -GroupBy { Convert-Path $_.PSParentPath } `
            -ItemStyle $itemStyleSelector `
            -GroupHeaderStyle $groupStyleSelector
}

Test 'custom styles colors' {
    $itemStyleSelector = {
        switch -regex ($_.Name) {
            '1' { @{ Foreground = [ConsoleColor]::Red } }
            '2' { @{ Foreground = [ConsoleColor]::Blue; Background = [ConsoleColor]::DarkCyan } }
            '3' { @{ Foreground = [ConsoleColor]::Green; Background = [ConsoleColor]::DarkGreen } }
        }
    }

    $groupStyle = @{
        Foreground = [ConsoleColor]::Red
        Background = [ConsoleColor]::DarkMagenta
        Underline = $true
    }

    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Show-Columns `
            -Property Name `
            -GroupBy { Convert-Path $_.PSParentPath } `
            -ItemStyle $itemStyleSelector `
            -GroupHeaderStyle $groupStyle
}

Test 'custom italic and underline colors' {
    $itemStyleSelector = {
        switch -regex ($_.Name) {
            '1' { @{ Foreground = [ConsoleColor]::Red; Italic = $true } }
            '2' { @{ Foreground = [ConsoleColor]::Blue; Background = [ConsoleColor]::DarkCyan } }
            '3' { @{ Foreground = [ConsoleColor]::Green; Background = [ConsoleColor]::DarkGreen } }
        }
    }

    $groupStyle = @{
        Foreground = [ConsoleColor]::Yellow
        Underline = $true
    }

    Get-ChildItem "$TestsDir\Subfolders" -Recurse `
        | Show-Columns `
            -Property Name `
            -GroupBy { Convert-Path $_.PSParentPath } `
            -ItemStyle $itemStyleSelector `
            -GroupHeaderStyle $groupStyle
}

Test 'grouping by missing property' {
    $items = @(
        @{ Name = 'First' }
        @{ Name = 'Second' }
        @{ Name = 'Third' }
    )

    $items | Show-Columns -Property Name -GroupBy InvalidName
}

Test 'displaying input strings in columns while property name is specified' {
    $items = @(
        'First'
        'Second'
        'Third'
    )

    $items | Show-Columns -Property OtherName
}
