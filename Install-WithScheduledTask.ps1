function Install-WithScheduledTask() {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][PSCustomObject] $arguments
    )

    $packageArgs = Get-Arguments $arguments

    if (-not (Test-FileExists $packageArgs.file)) {
        Write-Message "Downloading --> '$($packageArgs.url)'..."
        $packageArgs.file = Get-ChocolateyWebFile @packageArgs
    }

    Write-Message "Installing '$($packageArgs.file)'..."
    Invoke-ScheduledTask $packageArgs.packageName $packageArgs.file $packageArgs.silentArgs

    if (-not $packageArgs.skipSettings) {
        # If settings script exists for the package
        $settingsSceript = Join-Path $env:ChocolateyPackageFolder 'tool\Settings.ps1'
        if (Test-Path $settingsSceript) {
            # Include the source of the script so it runs in the current contxt
            . $settingsSceript
        }
    }
}