
function Assign-Color($color, $extensions) {
    foreach ($ext in $extensions) {
        if ($ext[0] -ne '.') {
            $ext = '.' + $ext
        }

        $colorRules[$ext] = $color
    }
}

$colorRules = @{}
$FolderColor = 'Blue'
Assign-Color 'Green' @('bat', 'cmd', 'exe', 'msi')
Assign-Color 'Magenta' @('bmp', 'gif', 'jpg', 'jpeg', 'pdn', 'png', 'psd', 'raw', 'tiff')
Assign-Color 'Red' @('7z', 'cab', 'gz', 'iso', 'rar', 'tar', 'zip')

function Sum-Array($items) {
    $sum = 0
    $count = $items.Length
    for ($i = 0; $i -lt $count; $i++) {
        $sum += $items[$i]
    }
    return $sum
}

function Get-CountPerColumn($itemCount, $columnCount) {
    return [Math]::Floor(($itemWidths.Length + $columnCount - 1) / $columnCount)
}

function Get-ColumnWidths($itemWidths, $columnCount) {
    $countPerColumn = Get-CountPerColumn $itemWidths.Length $columnCount
    $columnWidths = @(0) * $columnCount
    $itemCount = $itemWidths.Length

    for ($index = 0; $index -lt $itemCount; $index++) {
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

function Write-Spaces($count) {
    Write-Host (' ' * $count) -NoNewLine
}

function Write-Name($item) {
    if ($item.PSIsContainer) {
        $name = $item.Name + '/'
        $color = $FolderColor
    }
    else {
        $name = $item.Name
        $ext = [IO.Path]::GetExtension($item.Name).ToLower()
        $color = $colorRules[$ext]
        if (-not $color) {
            $color = 'White'
        }
    }

    Write-Host $name -NoNewLine -ForegroundColor:$color
}

function Write-Columns($items, $itemWidths, $spacing) {
    $columnWidths = Get-BestFittingColumns $itemWidths $spacing $Host.UI.RawUI.BufferSize.Width
    $countPerColumn = Get-CountPerColumn $items.Length $columnWidths.Length
    $columnCount = $columnWidths.Length

    for ($rowIndex = 0; $rowIndex -lt $countPerColumn; $rowIndex++) {
        for ($columnIndex = 0; $columnIndex -lt $columnCount; $columnIndex++) {
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

function New-ListItem($name, $foregroundColor, $backgroundColor) {
    $item = New-Object PSObject
    $item | Add-Member NoteProperty Name $name
    $item | Add-Member NoteProperty Width $name.Length
    $item | Add-Member NoteProperty ForegroundColor $foregroundColor
    $item | Add-Member NoteProperty BackgroundColor $backgroundColor
    return $item
}

function Format-Columns {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object] $InputObject
    )

    begin {
        $items = @()
        $itemWidths = @()
    }

    process {
        $items += $InputObject
        $width = $InputObject.Name.Length
        if ($InputObject.PSIsContainer) {
            $width += 1
        }
        $itemWidths += $width
    }

    end {
        Write-Columns $items $itemWidths 1
    }
}
