function Install-FromZip {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][PSCustomObject] $arguments
    )

    $packageArgs = Get-Arguments $arguments

    $originalFile = $packageArgs.file

    if (Test-FileExists $packageArgs.file) {
        Write-Message "Unzipping --> $($packageArgs.destination)"
        Get-ChocolateyUnzip  `
            -PackageName $packageArgs.packageName `
            -FileFullPath $packageArgs.file `
            -Destination $packageArgs.destination
    }
    elseif ($packageArgs.url) {
        Write-Message "Using Install-ChocolateyZipPackage..."

        Install-ChocolateyZipPackage `
            -PackageName $packageArgs.packageName `
            -Url $packageArgs.Url `
            -UnzipLocation $packageArgs.destination
    }

    if ($packageArgs.executableRegEx) {
        Write-Message "No Executable, Using Regex '$($packageArgs.executableRegEx)'..."
        $packageArgs.file = Get-Executable $packageArgs.destination $packageArgs.executableRegEx

        # Re-map the file type
        $packageArgs.fileType = Get-FileExtension $packageArgs.file
    }
    elseif ($packageArgs.executable) {
        Write-Message "Finding '$($packageArgs.executable)' in '$($packageArgs.destination)'..."

        # Re-map the file to the unzip executable
        $packageArgs.file = Join-Path $packageArgs.destination $packageArgs.executable
        $packageArgs.Remove('FileFullPath')

        # Re-map the file type
        $packageArgs.fileType = Get-FileExtension $packageArgs.file

        if ($packageArgs.executableArgs) {
            # Re-map the silent arguments
            $packageArgs.silentArgs = $packageArgs.executableArgs
        }
    }

    # The original zip was extracted and the file was re-maped
    if ($originalFile -ne $packageArgs.file) {
        Write-Message "Installing '$($packageArgs.file)'..."
        Install-ChocolateyInstallPackage @packageArgs
    }

    if ($packageArgs.cleanUp) {
        Get-ChildItem -Path $env:ChocolateyPackageFolder `
            -Include *.zip, *.7z, *.exe, *.msi, *.reg -Recurse -File | Remove-Item
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