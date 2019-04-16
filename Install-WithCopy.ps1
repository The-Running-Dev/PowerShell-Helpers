function Install-WithCopy {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][PSCustomObject] $arguments
    )

    $packageArgs = Get-Arguments $arguments
    $destinationFile = $packageArgs.file

    if (!(Test-FileExists $packageArgs.file)) {
        Write-Message "Downloading --> '$($arguments.url)'..."

        $arguments.file = Get-ChocolateyWebFile @packageArgs
    }

    $destinationFile = Join-Path $packageArgs.destination ([System.IO.Path]::GetFileName($packageArgs.file))

    if ($packageArgs.executable) {
        $destinationFile = Join-Path $packageArgs.destination $packageArgs.executable
    }

    Write-Message "Copying '$($packageArgs.file)' --> '$($packageArgs.destination)'..."

    New-Item -ItemType Directory $packageArgs.destination -Force | Out-Null
    Copy-Item $packageArgs.file $destinationFile -Force | Out-Null

    if (-not $packageArgs.skipSettings) {
        # If settings script exists for the package
        $settingsSceript = Join-Path $env:ChocolateyPackageFolder 'tool\Settings.ps1'
        if (Test-Path $settingsSceript) {
            # Include the source of the script so it runs in the current contxt
            . $settingsSceript
        }
    }
}