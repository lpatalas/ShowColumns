$ModulePath = (Split-Path $MyInvocation.MyCommand.Definition)

. "$ModulePath\Format-Columns.ps1"

Export-ModuleMember -Function Format-Columns