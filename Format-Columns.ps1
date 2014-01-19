function Sum-Array($items) {
    return ($items | Measure-Object -Sum).Sum
}

function Get-CountPerColumn($itemCount, $columnCount) {
    return [Math]::Floor(($itemWidths.Length + $columnCount - 1) / $columnCount)
}

function Get-ColumnWidths($itemWidths, $columnCount) {
    $countPerColumn = Get-CountPerColumn $itemWidths.Length $columnCount
    $columnWidths = @(0) * $columnCount

    for ($index = 0; $index -lt $itemWidths.Length; $index++) {
        $columnIndex = [Math]::Floor($index / $countPerColumn)
        if ($columnWidths[$columnIndex] -lt $itemWidths[$index]) {
            $columnWidths[$columnIndex] = $itemWidths[$index]
        }
    }

    return $columnWidths
}

function Get-BestFittingColumns($itemWidths, $spacing, $availableWidth) {
    $columnCount = $itemWidths.Length
    $columnWidths = $itemWidths
    $foundBestFit = $false

    while ((-not $foundBestFit) -and ($columnCount -gt 1)) {
        $columnWidths = Get-ColumnWidths $itemWidths $columnCount
        $totalWidth = (Sum-Array($columnWidths)) + ($spacing * ($columnCount - 1))

        if ($totalWidth -le $availableWidth) {
            $foundBestFit = $true
        }
        else {
            $columnCount--
        }
    }

    return $columnWidths
}

function Get-Widths($items) {
    $items | ForEach-Object {
        if ($_.IsPsContainer) {
            $_.Name.Length + 1
        }
        else {
            $_.Name.Length
        }
    }
}

function Write-Spaces($count) {
    Write-Host (' ' * $count) -NoNewLine
}

function Write-Name($item) {
    Write-Host $item.Name -NoNewLine
    if ($item.IsPsContainer) {
        Write-Host "\" -NoNewLine
    }
}

function Write-Columns($items, $spacing) {
    $itemWidths = Get-Widths $items
    $columnWidths = Get-BestFittingColumns $itemWidths $spacing $Host.UI.RawUI.BufferSize.Width
    $countPerColumn = Get-CountPerColumn $items.Length $columnWidths.Length

    for ($rowIndex = 0; $rowIndex -lt $countPerColumn; $rowIndex++) {
        for ($columnIndex = 0; $columnIndex -lt $columnWidths.Length; $columnIndex++) {
            $itemIndex = $columnIndex * $countPerColumn + $rowIndex
            $item = $items[$itemIndex]
            $columnWidth = $columnWidths[$columnIndex]
            $padding = $columnWidth - $itemWidths[$itemIndex]

            if ($itemIndex -lt $items.Length) {
                if ($columnIndex -gt 0) {
                    Write-Spaces $spacing
                }

                Write-Name $item
                Write-Spaces $padding
            }
        }

        Write-Host
    }
}

function Format-Columns {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object] $InputObject
    )

    begin {
        $pipedObjects = @()
    }

    process {
        $pipedObjects += $InputObject
    }

    end {
        Write-Columns $pipedObjects 1
    }
}
