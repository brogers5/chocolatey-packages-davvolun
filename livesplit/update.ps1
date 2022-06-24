Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$softwareRepo = 'LiveSplit/LiveSplit'

function global:au_GetLatest {
    return @{
        URL32 = Get-SoftwareUri
        Version = Get-LatestStableVersion
        ChecksumType32 = 'sha512'
    }
}

function global:au_BeforeUpdate ($Package)  {

}

function global:au_AfterUpdate ($Package)  {

}

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            "<licenseUrl>[^<]*</licenseUrl>" = "<licenseUrl>https://github.com/$($softwareRepo)/blob/$($Latest.Version)/LICENSE</licenseUrl>"
            "<projectSourceUrl>[^<]*</projectSourceUrl>" = "<projectSourceUrl>https://github.com/$($softwareRepo)/tree/$($Latest.Version)</projectSourceUrl>"
            "<releaseNotes>[^<]*</releaseNotes>" = "<releaseNotes>https://github.com/$($softwareRepo)/releases/tag/$($Latest.Version)</releaseNotes>"
        }
        'tools\chocolateyinstall.ps1' = @{
            "(^[$]?\s*url\s*=\s*)('.*')" = "`$1'$($Latest.URL32)'"
            "(^[$]?\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

Update-Package -ChecksumFor 32 -NoReadme
