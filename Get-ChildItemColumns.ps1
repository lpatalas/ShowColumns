
function Get-ChildItemColumns {
    [CmdletBinding(DefaultParameterSetName = "Items")]
    param(
        [String[]] $Exclude,
        [String] $Filter,
        [switch] $Force,
        [String[]] $Include,

        [Parameter(Mandatory = $true, ParameterSetName = "LiteralItems")]
        [String[]] $LiteralPath,

        [Parameter(ParameterSetName = "Items", Position = 0)]
        [String[]] $Path
    )

    Get-ChildItem @PSBoundParameters | Format-Columns
}