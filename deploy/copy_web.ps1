# After: flutter build web
# Copies build/web -> deploy/web for git push to Render
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root "build\web"
$dest = Join-Path $root "deploy\web"
$index = Join-Path $src "index.html"
if (-not (Test-Path $index)) {
  throw "Not found: $index - run flutter build web from: $root"
}
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Get-ChildItem -Path $dest -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force
Write-Host "OK: copied to $dest - commit and push to deploy on Render."
