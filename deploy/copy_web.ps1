# نشر ويب إسناد لـ Render:
# - افتراضياً: flutter build web ثم نسخ build/web -> deploy/web
# - Render ينشر من deploy/web بعد commit + push لهذا المسار
param(
  [switch]$SkipBuild,
  [switch]$Push
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

if (-not $SkipBuild) {
  Write-Host "Building Flutter web (release)..."
  flutter build web --release
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build web failed (exit $LASTEXITCODE)"
  }
}

$src = Join-Path $root "build\web"
$dest = Join-Path $root "deploy\web"
$index = Join-Path $src "index.html"
if (-not (Test-Path $index)) {
  throw "Not found: $index - run without -SkipBuild, or run: flutter build web --release"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Get-ChildItem -Path $dest -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force
Write-Host "OK: copied fresh build to $dest"

if ($Push) {
  Write-Host "Git: staging deploy/web, commit, push (triggers Render)..."
  git add deploy/web
  $pending = git diff --cached --name-only deploy/web
  if (-not $pending) {
    Write-Host "No changes under deploy/web to commit (tree already matches build output?)."
  } else {
    $msg = "chore(web): deploy isnad web $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $msg
    git push
    if ($LASTEXITCODE -ne 0) {
      throw "git push failed (exit $LASTEXITCODE)"
    }
    Write-Host 'OK: pushed - Render should pick up a new deploy shortly.'
  }
} else {
  Write-Host 'Next: git add deploy/web; git commit; git push - or re-run: .\deploy\copy_web.ps1 -Push'
}
