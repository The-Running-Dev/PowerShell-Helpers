function Install-WithProcess {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][PSCustomObject] $arguments,
        [switch] $wait
    )

    $packageArgs = Get-Arguments $arguments

    if ((Test-FileExists $packageArgs.file)) {
        Write-Message "Installing '$($arguments.file)'..."

        if ($wait) {
            Start-Process $packageArgs.file $arguments.silentArgs -Wait -NoNewWindow
        }
        else {
            Start-Process $packageArgs.file $arguments.silentArgs -NoNewWindow
        }
    }
    else {
        throw 'No Installer or Url...'
    }
}