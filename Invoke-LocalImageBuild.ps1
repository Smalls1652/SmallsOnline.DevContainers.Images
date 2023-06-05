[CmdletBinding()]
param()

$scriptRoot = $PSScriptRoot

$dockerFiles = Get-ChildItem -Path $scriptRoot | Where-Object { $PSItem.Name -like "Dockerfile*" }

$imageNameRegex = [regex]::new("^Dockerfile\.(?'imageName'.+?)$")

$imageTag = [System.DateTimeOffset]::Now.UtcDateTime.ToString("yyyyMMddHHmmss")

foreach ($buildItem in $dockerFiles) {
    $imageNameRegexMatch = $imageNameRegex.Match($buildItem.Name)

    $imageName = "dev-container-$($imageNameRegexMatch.Groups["imageName"].Value)"

    podman build --tag "$($imageName)/$($imageTag)" --tag "$($imageName)/latest" --file "$($buildItem.FullName)"
}