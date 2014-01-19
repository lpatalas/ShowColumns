function New-ColorRule {
    param(
        [ScriptBlock] $predicate,
        [ConsoleColor] $foregroundColor,
        [ConsoleColor] $backgroundColor = 'Black'
    )

    $rule = New-Object PSObject
    $rule | Add-Member NoteProperty Predicate $predicate
    $rule | Add-Member NoteProperty BackgroundColor $backgroundColor
    $rule | Add-Member NoteProperty ForegroundColor $ForegroundColor
    return $rule
}

function New-RegexColorRule {
    param(
        [string] $Pattern,
        [ConsoleColor] $foregroundColor,
        [ConsoleColor] $backgroundColor = 'Black'
    )

    $predicate = { param($item) $item.Name -match $Pattern }.GetNewClosure()
    return New-ColorRule $predicate $foregroundColor $backgroundColor
}

$defaultRule = New-ColorRule { $false } 'White' 'Black'

$colorRules = @(
    New-ColorRule { $args[0].PSIsContainer } 'Blue'
    New-RegexColorRule '\.(bat|cmd|exe|msi|ps1)$' 'Green'
    New-RegexColorRule '\.(7z|iso|gz|rar|tar|zip)$' 'Red'
    New-RegexColorRule '\.(bmp|gif|jpg|jpeg|png|psd|tiff)$' 'Magenta'
)

function Get-ColorRule($item) {
    foreach ($rule in $colorRules) {
        if (Invoke-Command -ScriptBlock $rule.Predicate -Args $item) {
            return $rule
        }
    }

    return $defaultRule
}

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
    $items | %{ $_.Width }
}

function Write-Spaces($count) {
    Write-Host (' ' * $count) -NoNewLine
}

function Write-Name($item) {
    Write-Host $item.Name -NoNewLine -ForegroundColor:$item.ForegroundColor -BackgroundColor:$item.BackgroundColor
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
    }

    process {
        $name = $InputObject.Name
        if ($InputObject.PSIsContainer) {
            $name += '/'
        }
        $colorRule = Get-ColorRule $InputObject

        $items += New-ListItem $name $colorRule.ForegroundColor $colorRule.BackgroundColor
    }

    end {
        Write-Columns $items 1
    }
}
