[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]]$ImagesToBuild
)

$scriptRoot = $PSScriptRoot

$dockerFiles = Get-ChildItem -Path $scriptRoot | Where-Object { $PSItem.Name -like "Dockerfile*" }

$imageNameRegex = [regex]::new("^Dockerfile\.(?'imageName'.+?)$")

$imageTag = [System.DateTimeOffset]::Now.UtcDateTime.ToString("yyyyMMddHHmmss")

foreach ($buildItem in $dockerFiles) {
    $imageNameRegexMatch = $imageNameRegex.Match($buildItem.Name)
    $baseImageName = $imageNameRegexMatch.Groups["imageName"].Value

    if ($null -ne $ImagesToBuild -and $baseImageName -notin $ImagesToBuild) {
        Write-Warning "Skipping '$($baseImageName)'."
    }
    else {
        $imageName = "dev-container-$($baseImageName)"

        Write-Verbose "Running 'podman buildx build --tag `"$($imageName):$($imageTag)`" --tag `"$($imageName):latest`" --file `"$($buildItem.FullName)`"'"
        podman buildx build --tag "$($imageName):$($imageTag)" --tag "$($imageName):latest" --file "$($buildItem.FullName)"
    }
}