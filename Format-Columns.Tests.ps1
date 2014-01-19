$CurrentDir = (Split-Path $MyInvocation.MyCommand.Definition)

. "$CurrentDir\Format-Columns.ps1"

function Assert-CollectionsEqual($expected, $actual) {
    function Write-Failure($additionalInfo = $null) {
        Write-Host "Failed - expected { $expected } but found { $actual }. $additionalInfo" -ForegroundColor Red
    }

    if ($expected.Length -ne $actual.Length) {
        Write-Failure "Sizes do not match $($expected.Length) != $($actual.Count)"
        return
    }

    for ($i = 0; $i -lt $expected.Length; $i++) {
        if ($expected[$i] -ne $actual[$i]) {
            Write-Failure "Items at index $i differ"
            break
        }
    }
}

function Test-GetColumnWidths {
    Write-Host "Testing Get-ColumnWidths..."

    function Test($widths, $columnCount, $expected) {
        $actual = @(Get-ColumnWidths $widths $columnCount)
        Assert-CollectionsEqual $expected $actual
    }

    Test @( 4 )                   1 @( 4 )
    Test @( 4, 8 )                1 @( 8 )
    Test @( 4, 8, 3, 5 )          2 @( 8, 5 )
    Test @( 1, 2, 3 )             2 @( 2, 3 )
    Test @( 1, 2, 3, 4, 5 )       3 @( 2, 4, 5 )
    Test @( 1, 2, 3, 4, 5, 6, 7 ) 3 @( 3, 6, 7 )
    Test @( 1, 15 )               1 @( 15 )
}

function Test-GetBestFittingColumns {
    Write-Host "Testing Get-BestFittingColumns..."

    $spacing = 1
    $availableWidth = 10

    function Test($widths, $expected) {
        $actual = @(Get-BestFittingColumns $widths $spacing $availableWidth)
        Assert-CollectionsEqual $expected $actual
    }

    Test @( 4 )             @( 4 )
    Test @( 4, 4 )          @( 4, 4 )
    Test @( 4, 4, 4)        @( 4, 4)
    Test @( 1, 1, 1, 1, 8 ) @( 1, 8 )
    Test @( 2, 15 )         @( 15 )
}

Test-GetColumnWidths
Test-GetBestFittingColumns

Write-Host "Measure Get-BestFittingColumns"
$widths = Get-ChildItem 'C:\' | %{ $_.Name.Length }
Measure-Command { Get-BestFittingColumns $widths 1 $Host.UI.RawUI.BufferSize.Width }

Write-Host "Measure Format-Columns"
Measure-Command { Get-ChildItem "C:\" | Format-Columns }