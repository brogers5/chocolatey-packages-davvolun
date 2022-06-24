$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath "livesplit.nuspec"

[xml] $nuspec = Get-Content "$nuspecFileRelativePath"
$version = [Version] $nuspec.package.metadata.version

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "", Scope="Module", Justification="Used in Get-RemoteFiles")]
$Latest = @{
    Url32 = Get-SoftwareUri -Version $version
    Version = $version
}

Write-Host "Downloading..."
Get-RemoteFiles -Purge -NoSuffix -Algorithm sha512

Write-Host "Creating package..."
choco pack $nuspecFileRelativePath
