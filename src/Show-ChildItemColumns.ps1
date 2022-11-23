$DefaultShowColumnsParameters = @{
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

    GroupBy = {
        Convert-Path $_.PSParentPath
    }
}

if ($PSStyle) {
    $DefaultShowColumnsParameters['ItemStyle'] = {
        if ($_.PSIsContainer) {
            return $PSStyle.FileInfo.Directory
        }
        else {
            if ($_.Extension) {
                return $PSStyle.FileInfo.Extension[$_.Extension]
            }
            else {
                return ''
            }
        }
    }
}
else {
    $DefaultShowColumnsParameters['ItemStyle'] = {
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
}

$GetChildItemsParameterNames = @{
    Desktop = @(
        'LiteralPath'
        'Path'
        'Filter'
        'Include'
        'Exclude'
        'Recurse'
        'Depth'
        'Force'
        'Attributes'
        'FollowSymlink'
        'UseTransaction'
        'Directory'
        'File'
        'Hidden'
        'ReadOnly'
        'System'
        'UseTransaction'
    )
    Core = @(
        'LiteralPath'
        'Path'
        'Filter'
        'Include'
        'Exclude'
        'Recurse'
        'Depth'
        'Force'
        'Attributes'
        'FollowSymlink'
        'UseTransaction'
        'Directory'
        'File'
        'Hidden'
        'ReadOnly'
        'System'
        'FollowSymlink'
    )
}

function Coalesce($a, $b) {
    if ($a) { $a } else { $b }
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

        [switch] $UseTransaction,

        [Alias('ad', 'd')]
        [switch] $Directory,

        [Alias('af')]
        [switch] $File,

        [Alias('ah', 'h')]
        [switch] $Hidden,

        [Alias('ar')]
        [switch] $ReadOnly,

        [Alias('as')]
        [switch] $System,

        [object] $GroupHeaderStyle,

        [object] $ItemStyle,

        [object] $Property,

        [object] $GroupBy
    )

    $boundParameters = $PSCmdlet.MyInvocation.BoundParameters
    $getChildItemParams = @{}
    $GetChildItemsParameterNames[$PSEdition] `
        | ForEach-Object {
            if ($boundParameters.ContainsKey($_)) {
                $getChildItemParams.Add($_, $boundParameters[$_])
            }
        }

    $showColumnsParams = @{
        GroupHeaderStyle = Coalesce $GroupHeaderStyle $DefaultShowColumnsParameters['GroupHeaderStyle']
        ItemStyle = Coalesce $ItemStyle $DefaultShowColumnsParameters['ItemStyle']
        Property = Coalesce $Property $DefaultShowColumnsParameters['Property']
    }

    if ($GroupBy) {
        $showColumnsParams['GroupBy'] = $GroupBy
    }
    elseif (($paths.Count -gt 1) -or $Recurse) {
        $showColumnsParams['GroupBy'] = $DefaultShowColumnsParameters['GroupBy']
    }

    Get-ChildItem @getChildItemParams `
        | Show-Columns @showColumnsParams
}
