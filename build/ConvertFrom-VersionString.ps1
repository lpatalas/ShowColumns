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

$isMatch = $baseVersion -match '(\d+)\.(\d+)\.(\d+)'
if (-not $isMatch) {
    throw "Can't parse minor.major.patch from string '$baseVersion'"
}

$major = [Int32]::Parse($matches[1])
$minor = [Int32]::Parse($matches[2])
$patch = [Int32]::Parse($matches[3])
$comparableBaseVersion = $major.ToString('000') + '.' + $minor.ToString('000') + '.' + $patch.ToString('000')

$version = [PSCustomObject]@{
    BaseVersion = $baseVersion
    PrereleaseLabel = $prereleaseLabel
    PrereleaseNumber = $prerelaseNumber
    Major = $major
    Minor = $minor
    Patch = $patch
    ComparableBaseVersion = $comparableBaseVersion
}

$version | Add-Member `
    -MemberType ScriptMethod `
    -Name ToString `
    -Force `
    -Value {
        if ($this.PrereleaseLabel) {
            $v = $this.BaseVersion
            $pre = $this.PrereleaseLabel
            $n = $this.PrereleaseNumber.ToString('000')
            return "$v-$pre$n"
        }
        else {
            return $this.BaseVersion
        }
    }

return $version