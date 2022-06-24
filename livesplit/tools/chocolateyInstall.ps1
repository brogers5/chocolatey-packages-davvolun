$ErrorActionPreference = 'Stop'

$toolsPath   = Split-Path -parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = 'livesplit'
  url            = 'https://github.com/LiveSplit/LiveSplit/releases/download/1.8.15/LiveSplit_1.8.15.zip'
  checksum       = '51f3cb1d32bd57fb4b469f491ee2efd9bd6bcc5dc836f76606483c124928e15f40513c0c709a9d45153266ad85247e0ab586523342d45397a29a5f455dbfd4cb'
  checksumType   = 'sha512'
  unzipLocation  = $toolsPath
}
Install-ChocolateyZipPackage @packageArgs

# exclude generate shim(s)
$ignoreFiles = @(
  'LiveSplit.Register.exe.ignore'
)

$zipName = [System.IO.Path]::GetFileNameWithoutExtension($packageArgs.url)

foreach($ignoreFile in $ignoreFiles) {
  New-Item "${toolsPath}\${ignoreFile}" -type file -force | Out-Null
}