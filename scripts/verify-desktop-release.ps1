param(
  [Parameter(Mandatory=$true)][string]$ArchivePath,
  [Parameter(Mandatory=$true)][ValidateSet('windows','macos')][string]$Platform,
  [Parameter(Mandatory=$true)][string]$ExpectedVersion,
  [Parameter(Mandatory=$true)][string]$ExpectedBuild
)

$ErrorActionPreference = 'Stop'

$archive = [IO.Path]::GetFullPath($ArchivePath)
if (!(Test-Path -LiteralPath $archive)) {
  throw "Release archive not found: $archive"
}

$verifyRoot = Join-Path ([IO.Path]::GetTempPath()) ("ovdp-release-smoke-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $verifyRoot -Force | Out-Null

try {
  if ($Platform -eq 'macos') {
    & /usr/bin/ditto -x -k $archive $verifyRoot
    if ($LASTEXITCODE -ne 0) { throw 'Could not extract macOS release ZIP' }
  } else {
    Expand-Archive -LiteralPath $archive -DestinationPath $verifyRoot -Force
  }

  $buildInfo = Get-ChildItem -LiteralPath $verifyRoot -Filter 'build-info.json' -File -Recurse | Select-Object -First 1
  if ($null -eq $buildInfo) {
    throw 'Packaged release is missing build-info.json'
  }
  $meta = Get-Content -LiteralPath $buildInfo.FullName -Raw | ConvertFrom-Json
  if ([string]$meta.version -ne $ExpectedVersion) {
    throw "Package metadata version mismatch: expected $ExpectedVersion, got $($meta.version)"
  }
  if ([string]$meta.build -ne $ExpectedBuild) {
    throw "Package metadata build mismatch: expected $ExpectedBuild, got $($meta.build)"
  }

  if ($Platform -eq 'windows') {
    $binary = Get-ChildItem -LiteralPath $verifyRoot -Filter 'ovdp_hub.exe' -File -Recurse | Select-Object -First 1
  } else {
    $binary = Get-ChildItem -LiteralPath $verifyRoot -File -Recurse |
      Where-Object { $_.FullName -match 'ovdp_hub\.app[/\\]Contents[/\\]MacOS[/\\]ovdp_hub$' } |
      Select-Object -First 1
  }
  if ($null -eq $binary) {
    throw "Packaged $Platform executable not found"
  }

  if ($Platform -eq 'macos') {
    & /bin/chmod +x $binary.FullName
    if ($LASTEXITCODE -ne 0) { throw 'Could not mark packaged macOS binary executable for smoke test' }
  }

  $contractFile = Join-Path $verifyRoot 'runtime-release-contract.json'
  $previousContractFile = $env:OVDP_RELEASE_CONTRACT_FILE
  try {
    $env:OVDP_RELEASE_CONTRACT_FILE = $contractFile
    if ($Platform -eq 'windows') {
      $process = Start-Process -FilePath $binary.FullName -Wait -PassThru
      if ($process.ExitCode -ne 0) {
        throw "Packaged executable release-contract failed with exit code $($process.ExitCode)"
      }
    } else {
      & $binary.FullName
      if ($LASTEXITCODE -ne 0) {
        throw "Packaged executable release-contract failed with exit code $LASTEXITCODE"
      }
    }
  }
  finally {
    if ($null -eq $previousContractFile) {
      Remove-Item Env:OVDP_RELEASE_CONTRACT_FILE -ErrorAction SilentlyContinue
    } else {
      $env:OVDP_RELEASE_CONTRACT_FILE = $previousContractFile
    }
  }
  if (!(Test-Path -LiteralPath $contractFile)) {
    throw 'Packaged executable did not write release-contract JSON'
  }
  $contract = Get-Content -LiteralPath $contractFile -Raw | ConvertFrom-Json

  if ([string]$contract.product -ne 'OVDP Hub') {
    throw "Unexpected product in executable: $($contract.product)"
  }
  if ([string]$contract.version -ne $ExpectedVersion) {
    throw "Executable version mismatch: expected $ExpectedVersion, got $($contract.version)"
  }
  if ([string]$contract.build -ne $ExpectedBuild) {
    throw "Executable build mismatch: expected $ExpectedBuild, got $($contract.build)"
  }
  if ([string]$contract.displayVersion -ne "$ExpectedVersion+$ExpectedBuild") {
    throw "Executable displayVersion mismatch: expected $ExpectedVersion+$ExpectedBuild, got $($contract.displayVersion)"
  }
  if ([string]$contract.defaultAppearance -ne 'studio') {
    throw "Unexpected default appearance: $($contract.defaultAppearance)"
  }

  $actualAppearances = @($contract.appearances)
  $expectedAppearances = @('classic','studio','dashboard')
  if ($actualAppearances.Count -ne $expectedAppearances.Count) {
    throw "Expected exactly 3 appearances, got $($actualAppearances.Count): $($actualAppearances -join ',')"
  }
  for ($i = 0; $i -lt $expectedAppearances.Count; $i++) {
    if ([string]$actualAppearances[$i] -ne $expectedAppearances[$i]) {
      throw "Appearance contract mismatch at index $($i): expected $($expectedAppearances[$i]), got $($actualAppearances[$i])"
    }
  }

  if ([string]$contract.appearanceLabelsUk.classic -ne 'Класичний дизайн') {
    throw 'Classic appearance label is missing from packaged executable contract'
  }
  if ([string]$contract.appearanceLabelsUk.studio -ne 'Дизайн «Робочий кабінет»') {
    throw 'Studio appearance label is missing from packaged executable contract'
  }
  if ([string]$contract.appearanceLabelsUk.dashboard -ne 'Дизайн «Світла панель»') {
    throw 'Light Dashboard appearance label is missing from packaged executable contract'
  }

  if ($Platform -eq 'macos') {
    $vaultSmokeFile = Join-Path $verifyRoot 'runtime-macos-vault-smoke.json'
    $previousVaultSmokeFile = $env:OVDP_MACOS_VAULT_SMOKE_FILE
    try {
      $env:OVDP_MACOS_VAULT_SMOKE_FILE = $vaultSmokeFile
      & $binary.FullName
      if ($LASTEXITCODE -ne 0) {
        throw "Packaged macOS Keychain/vault runtime smoke failed with exit code $LASTEXITCODE"
      }
    }
    finally {
      if ($null -eq $previousVaultSmokeFile) {
        Remove-Item Env:OVDP_MACOS_VAULT_SMOKE_FILE -ErrorAction SilentlyContinue
      } else {
        $env:OVDP_MACOS_VAULT_SMOKE_FILE = $previousVaultSmokeFile
      }
    }

    if (!(Test-Path -LiteralPath $vaultSmokeFile)) {
      throw 'Packaged macOS executable did not write vault runtime smoke JSON'
    }
    $vaultSmoke = Get-Content -LiteralPath $vaultSmokeFile -Raw | ConvertFrom-Json
    if ([string]$vaultSmoke.platform -ne 'macos') {
      throw "Unexpected vault smoke platform: $($vaultSmoke.platform)"
    }
    foreach ($field in @('success','keychainRoundTrip','sessionLockReopen','backupRestore','recoveryRotation','cleanup')) {
      if ($vaultSmoke.$field -ne $true) {
        throw "macOS vault runtime smoke field '$field' is not true. Error: $($vaultSmoke.error)"
      }
    }
    Write-Host 'PASS: packaged macOS app completed real Keychain/vault create-open-lock-reopen-backup-restore-rotation-cleanup smoke.'
  }

  Write-Host "PASS: packaged $Platform artifact $ExpectedVersion+$ExpectedBuild exposes classic/studio/dashboard."
}
finally {
  if (Test-Path -LiteralPath $verifyRoot) {
    Remove-Item -LiteralPath $verifyRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
