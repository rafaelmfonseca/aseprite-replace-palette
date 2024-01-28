$src = (Get-Location).Path
$dst = "$env:APPDATA\Aseprite\extensions\aseprite-replace-palette"

New-Item -ItemType SymbolicLink -Path $dst -Value $src
