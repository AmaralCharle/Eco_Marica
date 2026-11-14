param([string]$Godot = 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe')
$projectRoot = Split-Path -Parent $PSScriptRoot
$totalChecks = 0
$failedSuites = 0
$testFiles = Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'test_*.gd' | Sort-Object Name
foreach ($testFile in $testFiles) {
    $toolOutput = & $Godot --headless --path $projectRoot --script ('res://tests/' + $testFile.Name) 2>&1
    $testExitCode = $LASTEXITCODE
    $logPath = Join-Path $PSScriptRoot ('artifacts/' + $testFile.BaseName + '.log')
    $toolOutput | Out-File -LiteralPath $logPath -Encoding utf8
    $logText = $toolOutput -join "`n"
    $result = [regex]::Match($logText, 'RESULT: (\d+) verifica.+?, (\d+) falhas')
    if ($result.Success) { $totalChecks += [int]$result.Groups[1].Value }
    if ($testExitCode -ne 0 -or -not $result.Success -or $logText -match 'SCRIPT ERROR:|ERROR:' -or ($result.Success -and [int]$result.Groups[2].Value -ne 0)) {
        $failedSuites++
        Write-Output ('FAIL ' + $testFile.Name + ' -> ' + $logPath)
    } else { Write-Output ('PASS ' + $testFile.Name + ': ' + $result.Groups[1].Value) }
}
Write-Output ('TOTAL: ' + $totalChecks + ' verificacoes; ' + $failedSuites + ' suites com falha.')
if ($failedSuites -gt 0) { exit 1 }
exit 0
