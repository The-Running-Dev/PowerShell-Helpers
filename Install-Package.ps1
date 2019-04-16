function Install-Package {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][PSCustomObject] $arguments
    )

    $packageArgs = Get-Arguments $arguments

    if (-not (Test-FileExists $packageArgs.file) -and $packageArgs.url) {
        Write-Message "Downloading '$($packageArgs.url)'..."

        $packageArgs.file = Get-ChocolateyWebFile `
            -PackageName $packageArgs.packageName `
            -Url $packageArgs.url `
            -FileFullPath $packageArgs.fileFullPath
    }

    Install-ChocolateyInstallPackage `
        -PackageName $packageArgs.packageName `
        -File $packageArgs.file `
        -FileType $packageArgs.fileType `
        -SilentArgs $packageArgs.silentArgs `
        -ValidExitCodes $packageArgs.validExitCodes

    if ($packageArgs.executable) {
        # The file parameter does not contain a full path
        if (![System.IO.Path]::IsPathRooted($packageArgs.executable)) {
            $packageArgs.executable = Join-Path $packageArgs.destination $packageArgs.executable
        }

        Install-ChocolateyInstallPackage `
            -PackageName $packageArgs.packageName `
            -File $packageArgs.executable `
            -FileType (Get-FileExtension $packageArgs.executable) `
            -SilentArgs $packageArgs.executableArgs `
            -ValidExitCodes $packageArgs.validExitCodes
    }

    if ($packageArgs.cleanUp) {
        Get-ChildItem -Path $env:ChocolateyPackageFolder `
            -Include *.zip, *.7z, *.tar.gz, *.exe, *.msi, *.reg -Recurse -File | Remove-Item
    }

    if (-not $packageArgs.skipSettings) {
        # If settings script exists for the package
        $settingsSceript = Join-Path $env:ChocolateyPackageFolder 'tool\Settings.ps1'
        if (Test-Path $settingsSceript) {
            # Include the source of the script so it runs in the current contxt
            . $settingsSceript
        }
    }
}
