
function AssignColor($color, $extensions) {
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
AssignColor 'Green' @('bat', 'cmd', 'exe', 'msi')
AssignColor 'Magenta' @('bmp', 'gif', 'jpg', 'jpeg', 'pdn', 'png', 'psd', 'raw', 'tiff')
AssignColor 'Red' @('7z', 'cab', 'gz', 'iso', 'rar', 'tar', 'zip')
AssignColor 'Yellow' @('c', 'cpp', 'cs', 'css', 'cxx', 'fs', 'h', 'hpp', 'hs', 'htm', 'html', 'java', 'js', 'ps1', 'psm1', 'py', 'sql', 'vb', 'xml', 'xsl')
AssignColor 'Cyan' @('csproj', 'sln', 'vbproj', 'vsproj', 'vsxproj')
AssignColor 'DarkGray' @('.gitattributes', '.gitignore', '.gitmodules', '.hgignore', '.hgtags')

function SumArray($items) {
    $sum = 0
    $count = $items.Length
    for ($i = 0; $i -lt $count; $i++) {
        $sum += $items[$i]
    }
    return $sum
}

function GetItemCountPerColumn($totalItemCount, $columnCount) {
    return [Math]::Floor(($totalItemCount + $columnCount - 1) / $columnCount)
}

function GetColumnWidths($itemWidths, $columnCount) {
    $countPerColumn = GetItemCountPerColumn $itemWidths.Length $columnCount
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

function GetBestFittingColumns($itemWidths, $spacing, $availableWidth) {
    $columnCount = $itemWidths.Length
    $columnWidths = $itemWidths
    $foundBestFit = $false

    while ((-not $foundBestFit) -and ($columnCount -gt 0)) {
        $columnWidths = GetColumnWidths $itemWidths $columnCount
        $totalWidth = (SumArray($columnWidths)) + ($spacing * ($columnCount - 1))

        if ($totalWidth -le $availableWidth) {
            $foundBestFit = $true
        }
        else {
            $columnCount--
        }
    }

    return $columnWidths
}

function WriteSpaces($count) {
    Write-Host (' ' * $count) -NoNewLine
}

function DecorateItemName($item, $maxWidth) {
    $name = $item.Name

    if ($name.Length -gt $maxWidth) {
        $name = $name.Substring(0, $maxWidth - 4) + '...'
    }

    if ($item.PSIsContainer) {
        $name += '/'
    }

    return $name
}

function GetItemColor($item) {
    if ($item.PSIsContainer) {
        $color = $FolderColor
    }
    else {
        $ext = [IO.Path]::GetExtension($item.Name).ToLower()
        $color = $colorRules[$ext]
        if (-not $color) {
            $color = 'White'
        }
    }

    return $color
}

function WriteName($item, $maxWidth) {
    $name = DecorateItemName $item $maxWidth

    if ($item.Attributes -match 'Hidden') {
        Write-Host $name -NoNewLine -ForegroundColor:$HiddenForeground -BackgroundColor:$HiddenBackground
    }
    else {
        $color = GetItemColor $item
        Write-Host $name -NoNewLine -ForegroundColor:$color
    }
}

function GetItemWidths($items) {
    return $items | ForEach-Object {
        $width = $_.Name.Length
        if ($_.PSIsContainer) {
            $width += 1
        }
        $width
    }
}

function WriteColumns($items, $spacing = 1) {
    $itemWidths = @( GetItemWidths $items )
    $bufferWidth = $Host.UI.RawUI.BufferSize.Width
    $columnWidths = @(GetBestFittingColumns $itemWidths $spacing $bufferWidth)
    $countPerColumn = GetItemCountPerColumn $items.Length $columnWidths.Length
    $columnCount = $columnWidths.Length

    for ($rowIndex = 0; $rowIndex -lt $countPerColumn; $rowIndex++) {
        for ($columnIndex = 0; $columnIndex -lt $columnCount; $columnIndex++) {
            $itemIndex = $columnIndex * $countPerColumn + $rowIndex
            $item = $items[$itemIndex]
            $columnWidth = $columnWidths[$columnIndex]

            if ($itemIndex -lt $items.Length) {
                if ($columnIndex -gt 0) {
                    WriteSpaces $spacing
                }

                WriteName $item $bufferWidth

                if ($columnIndex -lt ($columnCount - 1)) {
                    $padding = $columnWidth - $itemWidths[$itemIndex]
                    WriteSpaces $padding
                }
            }
        }

        if ($Host.UI.RawUI.CursorPosition.X -gt 0) {
            Write-Host
        }
    }
}

function CreateGroup($name, $order) {
    $group = New-Object PSObject
    $group | Add-Member NoteProperty Name $name
    $group | Add-Member NoteProperty Order $order
    $group | Add-Member NoteProperty Items @()
    $group
}

function GroupItems($items) {
    $groups = @{}
    $nextGroupOrder = 1

    foreach ($item in $items) {
        $groupName = $item.GroupName
        $group = $groups[$groupName]
        if (-not $group) {
            $group = CreateGroup $groupName $nextGroupOrder
            $groups.Add($groupName, $group)
            $nextGroupOrder++
        }

        $group.Items += @( $item )
    }

    return $groups.Values | Sort-Object Order
}

function WriteGroupedItems($items) {
    $groupedItems = GroupItems $items

    foreach ($group in $groupedItems) {
        $path = $group.Name

        if ($group.Order -gt 1) {
            Write-Host
        }

        Write-Host $path -ForegroundColor DarkGray
        WriteColumns $group.Items
    }
}

function GetItemName($item, $propertyName) {
    if ($propertyName) {
        return $item.$propertyName
    }
    elseif ($item.PSChildName) {
        # HACK: Special casing for provider items
        return $item.PSChildName
    }
    else {
        return $item.ToString()
    }
}

function GetGroupName($item, $groupByPropertyName) {
    $groupName = $null

    if ($groupByPropertyName) {
        $groupName = $item.$groupByPropertyName

        # HACK: Special casing for provider items
        if (($groupByPropertyName -ieq 'PSParentPath') -or ($groupByPropertyName -ieq 'PSPath')) {
            $groupName = Convert-Path $groupName
        }
    }

    return $groupName
}

function Format-Columns {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object] $InputObject,

        [Object] $Property,

        [Object] $GroupBy
    )

    begin {
        $items = New-Object System.Collections.ArrayList
    }

    process {
        $item = [PSCustomObject] @{
            Name = GetItemName $_ $Property
            GroupName = GetGroupName $_ $GroupBy
        }
        $items.Add($item) | Out-Null
    }

    end {
        if ($items) {
            if ($GroupBy) {
                WriteGroupedItems $items
            }
            else {
                WriteColumns $items
            }
        }
    }
}
