$script:stylePreset = @{
    ItemStyle = {
        if ($_.Attributes -match 'Hidden') {
            return @{ Foreground = 'White'; Background = 'DarkGray' }
        }
        elseif ($_.PSIsContainer) {
            return 'Blue'
        }
        else {
            switch -Regex ($_.Extension) {
                '\.(bat|cmd|exe|msi)$' { 'Green' }
                '\.(bmp|gif|jpg|jpeg|pdn|png|psd|raw|tiff)$' { 'Magenta' }
                '\.(7z|cab|gz|iso|nupkg|rar|tar|zip)$' { 'Red' }
                '\.(c|cpp|cs|css|cxx|fs|h|hpp|hs|htm|html|java|js|json|jsx|ps1|psd1|psm1|py|sql|toml|ts|tsx|vb|xml|xsl|yml)$' { 'Yellow' }
                '\.(csproj|sln|sqlproj|vbproj|vsproj|vsxproj)$' { 'Cyan' }
                '\.(gitattributes|gitignore|gitmodules|hgignore|hgtags)$' { 'DarkGray' }
                default { 'Gray' }
            }
        }
    }

    GroupHeaderStyle = @{
        Foreground = [ConsoleColor]::DarkGray
        Underline = $true
    }

    Property = {
        $name = $(
            if ($_.PSChildName) { $_.PSChildName }
            elseif ($_.Name) { $_.Name }
            else { $_.ToString() }
        )

        if ($_.PSIsContainer) {
            "$name/"
        }
        else {
            $name
        }
    }
}

function Show-ChildItemColumns {
    [CmdletBinding(DefaultParameterSetName = 'Items')]
    param(
        [Alias('PSPath')]
        [Parameter(Mandatory, ParameterSetName = 'LiteralItems', ValueFromPipelineByPropertyName)]
        [String] $LiteralPath,

        [Parameter(ParameterSetName = 'Items', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,

        [Parameter(Position = 1)]
        [String] $Filter,

        [String[]] $Include,

        [String[]] $Exclude,

        [Alias('s')]
        [switch] $Recurse,

        [UInt32] $Depth,

        [switch] $Force,

        [System.Management.Automation.FlagsExpression[System.IO.FileAttributes]] $Attributes,

        [switch] $FollowSymlink,

        [Alias('ad', 'd')]
        [switch] $Directory,

        [Alias('af')]
        [switch] $File,

        [Alias('ah', 'h')]
        [switch] $Hidden,

        [Alias('ar')]
        [switch] $ReadOnly,

        [Alias('as')]
        [switch] $System
    )

    begin {
        $paths = New-Object System.Collections.ArrayList
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'LiteralItems') {
            Write-Verbose "Processing LiteralPath: $LiteralPath"
            if ($LiteralPath) {
                $paths.AddRange($LiteralPath)
            }
        }
        else {
            Write-Verbose "Processing Path: $LiteralPath"
            if ($Path) {
                $paths.AddRange($Path)
            }
        }
    }

    end {
        Write-Verbose "Input item count: $($paths.Count)"

        if ($PSCmdlet.ParameterSetName -eq 'LiteralItems') {
            $PSBoundParameters['LiteralPath'] = $paths
        }
        else {
            $PSBoundParameters['Path'] = $paths
        }

        if (($paths.Count -gt 1) -or $Recurse) {
            $groupBy = { Convert-Path $_.PSParentPath }
        }

        Get-ChildItem @PSBoundParameters `
            | Show-Columns @script:stylePreset -GroupBy:$groupBy
    }
}
