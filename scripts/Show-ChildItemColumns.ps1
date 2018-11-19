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
                '\.(c|cpp|cs|css|cxx|fs|h|hpp|hs|htm|html|java|js|json|jsx|ps1|psm1|py|sql|toml|ts|tsx|vb|xml|xsl|yml)$' { 'Yellow' }
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
        if ($_.PSIsContainer) {
            $_.PSChildName + '/'
        }
        else {
            $_.PSChildName
        }
    }
}

function Show-ChildItemColumns {
    param(
        [Alias('PSPath')]
        [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName)]
        [String] $LiteralPath,

        [Parameter(ParameterSetName = 'Path', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
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

    if (($Path.Count -gt 1) -or $Recurse) {
        Get-ChildItem @PSBoundParameters `
            | Show-Columns @script:stylePreset `
                -GroupBy { Convert-Path $_.PSParentPath }
    }
    else {
        Get-ChildItem @PSBoundParameters `
            | Show-Columns @script:stylePreset
    }
}