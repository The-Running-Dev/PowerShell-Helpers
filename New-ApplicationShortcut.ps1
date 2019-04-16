function New-ApplicationShortcut {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)][ValidateScript( {Test-Path $_ -PathType Leaf})][string] $path
    )

    try {
        if ($path -match '\$') {
            $path = Invoke-Expression $path
        }

        if ([System.IO.File]::Exists($path)) {
            $applicationShortcut = $path -replace '\.\w+$', '.lnk'

            Write-Message "New-ApplicationShortcut: Shortcut '$applicationShortcut' --> '$path'..."

            Install-ChocolateyShortcut `
                -ShortcutFilePath $applicationShortcutPath `
                -TargetPath $path `
                -RunAsAdmin

            & $global:pinTool $path c:"Pin to taskbar" | Out-Null
        }
    }
    catch {
        Write-Message "Invoke-PinApplication Failed: $($_.Exception.Message)"
    }
}