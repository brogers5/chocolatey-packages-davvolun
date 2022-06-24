$ErrorActionPreference = 'Stop'

$toolsPath   = Split-Path -parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName = $env:ChocolateyPackageName
  destination = $toolsPath
  file        = "$toolsPath\LiveSplit_1.8.15.zip"
}

Get-ChocolateyUnzip @packageArgs

# exclude generate shim(s)
$ignoreFiles = @(
  'LiveSplit.Register.exe.ignore'
)

foreach($ignoreFile in $ignoreFiles) {
  New-Item "${toolsPath}\${ignoreFile}" -type file -force | Out-Null
}
