
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
$HiddenBackground = 'DarkGray'
$HiddenForeground = 'White'
Assign-Color 'Green' @('bat', 'cmd', 'exe', 'msi')
Assign-Color 'Magenta' @('bmp', 'gif', 'jpg', 'jpeg', 'pdn', 'png', 'psd', 'raw', 'tiff')
Assign-Color 'Red' @('7z', 'cab', 'gz', 'iso', 'rar', 'tar', 'zip')
Assign-Color 'Yellow' @('c', 'cpp', 'cs', 'css', 'cxx', 'fs', 'h', 'hpp', 'hs', 'htm', 'html', 'java', 'js', 'ps1', 'psm1', 'py', 'sql', 'vb', 'xml', 'xsl')
Assign-Color 'Cyan' @('csproj', 'sln', 'vbproj', 'vsproj', 'vsxproj')
Assign-Color 'DarkGray' @('.gitattributes', '.gitignore', '.gitmodules', '.hgignore', '.hgtags')

function Sum-Array($items) {
    $sum = 0
    $count = $items.Length
    for ($i = 0; $i -lt $count; $i++) {
        $sum += $items[$i]
    }
    return $sum
}

function Get-ItemCountPerColumn($totalItemCount, $columnCount) {
    return [Math]::Floor(($totalItemCount + $columnCount - 1) / $columnCount)
}

function Get-ColumnWidths($itemWidths, $columnCount) {
    $countPerColumn = Get-ItemCountPerColumn $itemWidths.Length $columnCount
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

    while ((-not $foundBestFit) -and ($columnCount -gt 0)) {
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

function Get-ItemName($item, $maxWidth) {
    $name = $item.PSChildName

    if ($name.Length -gt $maxWidth) {
        $name = $name.Substring(0, $maxWidth - 4) + '...'
    }

    if ($item.PSIsContainer) {
        $name += '/'
        $color = $FolderColor
    }

    return $name
}

function Get-ItemColor($item) {
    if ($item.PSIsContainer) {
        $color = $FolderColor
    }
    else {
        $ext = [IO.Path]::GetExtension($item.PSChildName).ToLower()
        $color = $colorRules[$ext]
        if (-not $color) {
            $color = 'White'
        }
    }

    return $color
}

function Write-Name($item, $maxWidth) {
    $name = Get-ItemName $item $maxWidth

    if ($item.Attributes -match 'Hidden') {
        Write-Host $name -NoNewLine -ForegroundColor:$HiddenForeground -BackgroundColor:$HiddenBackground
    }
    else {
        $color = Get-ItemColor $item
        Write-Host $name -NoNewLine -ForegroundColor:$color
    }
}

function Write-Columns($items, $itemWidths, $spacing) {
    $bufferWidth = $Host.UI.RawUI.BufferSize.Width
    $columnWidths = @(Get-BestFittingColumns $itemWidths $spacing $bufferWidth)
    $countPerColumn = Get-ItemCountPerColumn $items.Length $columnWidths.Length
    $columnCount = $columnWidths.Length

    for ($rowIndex = 0; $rowIndex -lt $countPerColumn; $rowIndex++) {
        for ($columnIndex = 0; $columnIndex -lt $columnCount; $columnIndex++) {
            $itemIndex = $columnIndex * $countPerColumn + $rowIndex
            $item = $items[$itemIndex]
            $columnWidth = $columnWidths[$columnIndex]

            if ($itemIndex -lt $items.Length) {
                if ($columnIndex -gt 0) {
                    Write-Spaces $spacing
                }

                Write-Name $item $bufferWidth

                if ($columnIndex -lt ($columnCount - 1)) {
                    $padding = $columnWidth - $itemWidths[$itemIndex]
                    Write-Spaces $padding
                }
            }
        }

        Write-Host
    }
}

function Show-Items($items, $widths, $directoryPath = "") {
    if ($items) {
        Write-Host

        if ($directoryPath) {
            $displayPath = (Convert-Path $directoryPath)
            Write-Host "$displayPath\" -ForegroundColor DarkGray
        }

        Write-Columns $items $widths 1
    }
}

function Show-GroupedItems($items, $itemWidths) {
    $dirItems = @()
    $dirWidths = @()
    $currentDir = ""
    $itemCount = $items.Length

    for ($i = 0; $i -lt $itemCount; $i++) {
        $item = $items[$i]

        if ($item.PSParentPath -ne $currentDir) {
            Show-Items $dirItems $dirWidths $currentDir

            $currentDir = $item.PSParentPath
            $dirItems = @()
            $dirWidths = @()
        }

        $dirItems += $item
        $dirWidths += $itemWidths[$i]
    }

    Show-Items $dirItems $dirWidths $currentDir
}

function Format-Columns {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object] $InputObject,

        [switch] $GroupByDirectory
    )

    begin {
        $items = @()
        $itemWidths = @()
    }

    process {
        $items += $InputObject
        $width = $InputObject.PSChildName.Length
        if ($InputObject.PSIsContainer) {
            $width += 1
        }
        $itemWidths += $width
    }

    end {
        if ($items) {
            if ($GroupByDirectory) {
                Show-GroupedItems $items $itemWidths
            }
            else {
                Write-Columns $items $itemWidths 1
            }
        }
    }
}
