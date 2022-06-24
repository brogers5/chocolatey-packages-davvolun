Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$toolsPath = Join-Path -Path $currentPath -ChildPath 'tools'

$softwareRepo = 'LiveSplit/LiveSplit'

function global:au_GetLatest {
    return @{
        URL32 = Get-SoftwareUri
        Version = Get-LatestStableVersion
        ChecksumType32 = 'sha512'
    }
}

function global:au_BeforeUpdate ($Package)  {
    Copy-Item -Path "$toolsPath\VERIFICATION.txt.template" -Destination "$toolsPath\VERIFICATION.txt" -Force

    Get-RemoteFiles -Purge -NoSuffix -Algorithm sha512

    #Get-RemoteFiles will extract the ZIP file contents, clean up unnecessary files
    $cleanExcludeList = @('chocolateyBeforeModify.ps1', 'chocolateyInstall.ps1', 'LICENSE.txt', 'VERIFICATION.txt', 'VERIFICATION.txt.template', 'LiveSplit_*.zip')
    Get-ChildItem -Path $toolsPath -Exclude $cleanExcludeList | Remove-Item -Recurse -Force
}

function global:au_AfterUpdate ($Package)  {
    $licenseUri = "https://raw.githubusercontent.com/$($softwareRepo)/$($Latest.Version)/LICENSE"
    $licenseContents = Invoke-WebRequest -Uri $licenseUri -UseBasicParsing

    Set-Content -Path 'tools\LICENSE.txt' -Value "From: $licenseUri`r`n`r`n$licenseContents"
}

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            "<releaseNotes>[^<]*</releaseNotes>" = "<releaseNotes>https://github.com/$($softwareRepo)/releases/tag/$($Latest.Version)</releaseNotes>"
        }
        'tools\VERIFICATION.txt' = @{
            '%checksumValue%' = "$($Latest.Checksum32)"
            '%checksumType%' = "$($Latest.ChecksumType32.ToUpper())"
            '%tagReleaseUrl%' = "https://github.com/$($softwareRepo)/releases/tag/$($Latest.Version)"
            '%binaryUrl%' = "$($Latest.URL32)"
            '%binaryFileName%' = "$($Latest.FileName32)"
        }	
        'tools\chocolateyinstall.ps1' = @{
            "(^\s*file\s*=\s*)(`".*`")$" = "`$1`"`$toolsPath\$($Latest.FileName32)`""
        }
    }
}

Update-Package -ChecksumFor None -NoReadme
