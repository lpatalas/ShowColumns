param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
    [String] $InputObject
)

$isMatch = $InputObject -imatch '^(?<base>\d+\.\d+\.\d+)(-(?<label>[a-z]+)(?<number>\d+))?$'
if (-not $isMatch) {
    throw "Can't parse version: $InputObject"
}

$baseVersion = $matches['base']
$prereleaseLabel = $matches['label']

if ($prereleaseLabel) {
    $prerelaseNumber = [Int32]::Parse($matches['number'].TrimStart('0'))
}

return [PSCustomObject]@{
    BaseVersion = $baseVersion
    PrereleaseLabel = $prereleaseLabel
    PrereleaseNumber = $prerelaseNumber
}