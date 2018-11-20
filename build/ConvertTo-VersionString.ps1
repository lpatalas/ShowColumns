param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
    [PSObject] $InputObject
)

if (-not $InputObject.BaseVersion) {
    throw 'Input version does not contain `BaseVersion` property'
}

if ($InputObject.PrereleaseLabel) {
    if (-not $InputObject.PrereleaseNumber) {
        throw 'Input version does not contain `PrereleaseNumber` property'
    }

    $v = $InputObject.BaseVersion
    $pre = $InputObject.PrereleaseLabel
    $n = $InputObject.PrereleaseNumber.ToString('000')

    return "$v-$pre$n"
}
else {
    return $InputObject.BaseVersion
}