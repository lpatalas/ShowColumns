$ModulePath = (Split-Path $MyInvocation.MyCommand.Definition)

. "$ModulePath\Format-Columns.ps1"
. "$ModulePath\Get-ChildItemColumns.ps1"

Export-ModuleMember -Function Format-Columns
Export-ModuleMember -Function Get-ChildItemColumns