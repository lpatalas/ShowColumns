
function Get-ChildItemColumns {
    [CmdletBinding(DefaultParameterSetName = "Items")]
    param(
        [String[]] $Exclude,

        [Parameter(Position = 1)]
        [String] $Filter,

        [switch] $Force,

        [String[]] $Include,

        [Parameter(Mandatory = $true, ParameterSetName = "LiteralItems")]
        [String[]] $LiteralPath,

        [Parameter(ParameterSetName = "Items", Position = 0)]
        [String[]] $Path,

        [switch] $Recurse
    )

    Get-ChildItem @PSBoundParameters | Format-Columns -GroupByDirectory:$Recurse
}