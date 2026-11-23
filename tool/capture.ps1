param(
    [string]$Device = 'emulator-5554',
    [string]$Flutter = 'flutter',
    [string]$Adb
)

$ErrorActionPreference = 'Stop'
if (-not $Adb) {
    $command = Get-Command adb -ErrorAction SilentlyContinue
    $sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } elseif ($env:ANDROID_SDK_ROOT) {
        $env:ANDROID_SDK_ROOT
    } else { Join-Path $env:LOCALAPPDATA 'Android/Sdk' }
    $Adb = if ($command) { $command.Source } else { Join-Path $sdk 'platform-tools/adb.exe' }
}

function Invoke-Device {
    & $Adb -s $Device @args
    if ($LASTEXITCODE -ne 0) { throw "ADB failed on $Device (exit code $LASTEXITCODE)." }
}

if ((Invoke-Device get-state).Trim() -ne 'device') {
    throw "Connect the Android device $Device before capturing screenshots."
}

$previousSize = [regex]::Match((Invoke-Device shell wm size) -join ' ', 'Override size:\s*(\d+x\d+)').Groups[1].Value
$previousDensity = [regex]::Match((Invoke-Device shell wm density) -join ' ', 'Override density:\s*(\d+)').Groups[1].Value

Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    Invoke-Device shell wm size 750x1624
    Invoke-Device shell wm density 320
    & $Flutter drive -d $Device --driver=test_driver/screenshots.dart --target=integration_test/screens_test.dart
    if ($LASTEXITCODE -ne 0) { throw "Flutter Drive failed (exit code $LASTEXITCODE)." }
} finally {
    try {
        Invoke-Device shell wm size $(if ($previousSize) { $previousSize } else { 'reset' })
    } finally {
        try {
            Invoke-Device shell wm density $(if ($previousDensity) { $previousDensity } else { 'reset' })
        } finally {
            Pop-Location
        }
    }
}

