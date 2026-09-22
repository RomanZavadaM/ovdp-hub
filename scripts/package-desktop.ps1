param([Parameter(Mandatory=$true)][ValidateSet('windows','macos')][string]$Platform)
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$project = [IO.Path]::GetFullPath((Join-Path $repoRoot 'apps/native'))
$versionLine = Get-Content (Join-Path $project 'pubspec.yaml') | Where-Object { $_ -match '^version:' }
if ($versionLine -notmatch '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$') { throw 'Invalid app version' }
$version = $Matches[1]
$build = $Matches[2]
$revision = if ($env:GITHUB_SHA) { $env:GITHUB_SHA.Substring(0,7) } else { 'local' }
$run = if ($env:GITHUB_RUN_NUMBER) { "$($env:GITHUB_RUN_NUMBER)-$($env:GITHUB_RUN_ATTEMPT)" } else { Get-Date -Format 'yyyyMMdd-HHmmss' }
$name = "OVDP-Hub-$version-b$build-$Platform-$run-$revision"
$packageRoot = Join-Path $project 'build/packages'
$folder = Join-Path $packageRoot $name
if (Test-Path -LiteralPath $folder) { throw 'Package already exists; use a new build identity' }
New-Item -ItemType Directory -Path $folder -Force | Out-Null
if ($Platform -eq 'windows') {
  $source = Join-Path $project 'build/windows/x64/runner/Release'
  if (!(Test-Path -LiteralPath (Join-Path $source 'ovdp_hub.exe'))) { throw 'Windows executable not found' }
  Get-ChildItem -LiteralPath $source | Copy-Item -Destination $folder -Recurse
} else {
  $source = Join-Path $project 'build/macos/Build/Products/Release/ovdp_hub.app'
  if (!(Test-Path -LiteralPath $source)) { throw 'macOS application not found' }
  & /usr/bin/ditto $source (Join-Path $folder 'ovdp_hub.app')
  if ($LASTEXITCODE -ne 0) { throw 'macOS copy failed' }
}
@"
OVDP Hub $version (build $build)
Platform: $Platform | Revision: $revision | CI run: $run

Extract this entire folder. Keep the executable, libraries and data together.
Windows: open ovdp_hub.exe. macOS: open ovdp_hub.app.
No development server or SDK is required. This test build is unsigned.
Your workspace is stored separately; changing this program folder does not delete it.
Planner defaults to nominal-value estimates, NOT executable broker prices.
Test: save a scenario, restart, reopen it; copy your workspace to an empty folder.
"@ | Set-Content -LiteralPath (Join-Path $folder 'TESTING.txt') -Encoding utf8
$legalFiles = @(
  @{ Source = (Join-Path $repoRoot 'LICENSE.md'); Target = 'LICENSE.md' },
  @{ Source = (Join-Path $repoRoot 'COPYRIGHT.md'); Target = 'COPYRIGHT.md' },
  @{ Source = (Join-Path $repoRoot 'THIRD_PARTY_NOTICES.md'); Target = 'THIRD_PARTY_NOTICES.md' },
  @{ Source = (Join-Path $repoRoot 'docs/LEGAL_AND_COPYRIGHT.md'); Target = 'LEGAL_AND_COPYRIGHT.md' }
)
foreach ($legal in $legalFiles) {
  if (!(Test-Path -LiteralPath $legal.Source)) { throw "Missing legal notice: $($legal.Source)" }
  Copy-Item -LiteralPath $legal.Source -Destination (Join-Path $folder $legal.Target)
}
@{version=$version; build=$build; platform=$Platform; revision=$revision; run=$run} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $folder 'build-info.json') -Encoding utf8
$archive = Join-Path $packageRoot "$name.zip"
if ($Platform -eq 'macos') {
  & /usr/bin/ditto -c -k --sequesterRsrc --keepParent $folder $archive
  if ($LASTEXITCODE -ne 0) { throw 'macOS archive failed' }
} else { Compress-Archive -LiteralPath $folder -DestinationPath $archive }
if ($env:GITHUB_OUTPUT) {
  "package_name=$name" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
  "package_path=$archive" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}
Write-Output $archive
