function New-ApplicationPin {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)][ValidateScript( {Test-Path $_ -PathType Leaf})][string] $path,
        [Parameter(Position = 1)][string] $arguments
    )

    try {
        if ($path -match '\$') {
            $path = Invoke-Expression $path
        }

        if ([System.IO.File]::Exists($path)) {
            $shortcutPath = $path -replace '\.\w+$', '.lnk'

            Write-Message "Pinning '$shortcutPath' --> '$path'..."

            Install-ChocolateyShortcut `
                -ShortcutFilePath $shortcutPath `
                -TargetPath $path `
                -Arguments $arguments `
                -RunAsAdmin

            & $global:pinTool $path c:"Pin to taskbar" | Out-Null
        }
        else {
            throw "$path Does Not Exist..."
        }
    }
    catch {
        Write-Message "Invoke-PinApplication Failed: $($_.Exception.Message)"
    }
}