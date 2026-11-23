param(
    [string]$Device = 'emulator-5554',
    [string[]]$Only,
    [switch]$SkipBuild,
    [switch]$SkipInstall,
    [ValidateRange(300, 10000)][int]$CaptureDelayMs = 1250
)

$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content (Join-Path $PSScriptRoot 'screens.json') -Raw | ConvertFrom-Json
$screens = @($manifest | Where-Object { !$Only -or $_.route -in $Only })
if (!$screens.Count) { throw 'No matching capture routes.' }

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
$adb = if ($adbCommand) {
    $adbCommand.Source
} elseif ($env:ANDROID_HOME) {
    Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'
} else {
    Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
}
if (!(Test-Path -LiteralPath $adb)) { throw "Cannot find adb: $adb" }

function Invoke-Device {
    $result = & $adb -s $Device @args
    if ($LASTEXITCODE -ne 0) { throw "adb $($args -join ' ') failed." }
    return $result
}

if ((Invoke-Device get-state) -ne 'device') { throw "Device is unavailable: $Device" }
$output = Join-Path $project 'docs\screenshots'
New-Item -ItemType Directory -Path $output -Force | Out-Null
$remoteFile = '/sdcard/grabite-capture.png'
$remoteTree = '/sdcard/grabite-capture.xml'
$imeScreens = @('forgot', 'phone', 'phoneActive', 'verify', 'addressEntry', 'searching')
$app = 'com.grabite.grabite'
$activity = "$app/.MainActivity"

function Show-Input {
    $dump = Invoke-Device shell uiautomator dump $remoteTree
    if ($dump -notmatch 'dumped to') { return }
    [xml]$tree = (Invoke-Device shell cat $remoteTree) -join [Environment]::NewLine
    $field = $tree.SelectSingleNode('//node[@class="android.widget.EditText"]')
    if (!$field) { return }
    $bounds = [regex]::Matches($field.bounds, '\d+')
    $x = [int](([int]$bounds[0].Value + [int]$bounds[2].Value) / 2)
    $y = [int](([int]$bounds[1].Value + [int]$bounds[3].Value) / 2)
    Invoke-Device shell input tap $x $y | Out-Null
    Start-Sleep -Milliseconds 500
}

function Save-Frame([string]$destination) {
    for ($attempt = 0; $attempt -lt 3; $attempt++) {
        Invoke-Device shell screencap -p $remoteFile | Out-Null
        Invoke-Device pull $remoteFile $destination | Out-Null
        if ((Get-Item -LiteralPath $destination).Length -ge 20KB) { return }
        Start-Sleep -Milliseconds 2000
    }
    throw "No rendered app frame for $destination."
}

Push-Location $project
try {
    if (!$SkipBuild) {
        flutter build apk --debug --target-platform android-x64 --target tool/screenshot_app.dart
        if ($LASTEXITCODE -ne 0) { throw 'Screenshot APK build failed.' }
    }
    if (!$SkipInstall) {
        Invoke-Device install -r 'build\app\outputs\flutter-apk\app-debug.apk' | Out-Null
    }
    $sizeOverride = Invoke-Device shell wm size | Select-String 'Override size: (\d+x\d+)'
    $densityOverride = Invoke-Device shell wm density | Select-String 'Override density: (\d+)'
    $restoreSize = if ($sizeOverride) { $sizeOverride.Matches[0].Groups[1].Value } else { 'reset' }
    $restoreDensity = if ($densityOverride) { $densityOverride.Matches[0].Groups[1].Value } else { 'reset' }
    $keyboardSetting = Invoke-Device shell settings get secure show_ime_with_hard_keyboard
    try {
        Invoke-Device shell wm size 750x1624 | Out-Null
        Invoke-Device shell wm density 320 | Out-Null
        Invoke-Device shell settings put secure show_ime_with_hard_keyboard 1 | Out-Null
        $delay = [Math]::Max($CaptureDelayMs, 3500)
        foreach ($screen in $screens) {
            $launch = Invoke-Device shell am start -S -W -n $activity --es route "/$($screen.route)"
            if ($launch -match '^Error') { throw ($launch -join [Environment]::NewLine) }
            Start-Sleep -Milliseconds $delay
            $delay = $CaptureDelayMs
            if ($screen.route -in $imeScreens) { Show-Input }
            Save-Frame (Join-Path $output $screen.file)
            Write-Host "Captured $($screen.file)"
        }
    } finally {
        & $adb -s $Device shell am force-stop $app | Out-Null
        & $adb -s $Device shell rm -f $remoteFile $remoteTree | Out-Null
        & $adb -s $Device shell wm size $restoreSize | Out-Null
        & $adb -s $Device shell wm density $restoreDensity | Out-Null
        if ($keyboardSetting -eq 'null') {
            & $adb -s $Device shell settings delete secure show_ime_with_hard_keyboard | Out-Null
        } else {
            & $adb -s $Device shell settings put secure show_ime_with_hard_keyboard $keyboardSetting | Out-Null
        }
    }
} finally {
    Pop-Location
}
