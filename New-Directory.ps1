function New-Directory {
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)][ValidateNotNullOrEmpty()][string] $path
    )

    if ([System.IO.File]::Exists($path)) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    New-Item -ItemType Directory -Force -Path $path | Out-Null
}