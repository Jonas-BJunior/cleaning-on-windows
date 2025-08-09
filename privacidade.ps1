# =========================
# Script de Privacidade Windows
# =========================

Write-Host "Iniciando ajustes de privacidade..." -ForegroundColor Green

# ----- Desativar Telemetria -----
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Type DWord -Value 0

# ----- Desativar Experiências do Consumidor -----
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableConsumerFeatures -Type DWord -Value 1

# ----- Desativar Cortana -----
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -Type DWord -Value 0

# ----- Desativar OneDrive -----
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name DisableFileSyncNGSC -Type DWord -Value 1

# ----- Bloquear domínios de telemetria no hosts -----
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @(
    "vortex.data.microsoft.com",
    "telecommand.telemetry.microsoft.com",
    "telemetry.microsoft.com",
    "oca.telemetry.microsoft.com",
    "sqm.telemetry.microsoft.com"
)

Write-Host "Atualizando arquivo hosts..." -ForegroundColor Cyan

try {
    $hostsContent = Get-Content $hostsPath -Raw
    $toAdd = @()

    foreach ($d in $domains) {
        if ($hostsContent -notmatch [regex]::Escape($d)) {
            $toAdd += "0.0.0.0 $d"
        }
    }

    if ($toAdd.Count -eq 0) {
        Write-Host "Domínios de telemetria já bloqueados no hosts." -ForegroundColor Yellow
    }
    else {
        $newContent = $hostsContent.TrimEnd() + "`n# Bloqueio Telemetria Microsoft`n" + ($toAdd -join "`n") + "`n"
        Set-Content -Path $hostsPath -Value $newContent -Force
        Write-Host "Domínios adicionados no hosts." -ForegroundColor Green
    }
}
catch {
    Write-Host "Falha ao atualizar arquivo hosts: $($_.Exception.Message)" -ForegroundColor Red
}

# ----- Desativar Serviços de Telemetria -----
$services = @("diagtrack", "dmwappushservice")
foreach ($svc in $services) {
    Write-Host "Parando e desabilitando serviço: $svc"
    try {
        Stop-Service $svc -Force -ErrorAction Stop
        Set-Service $svc -StartupType Disabled
        Write-Host "Serviço $svc desativado com sucesso." -ForegroundColor Green
    }
    catch {
        Write-Host ("Falha ao modificar serviço {0}: {1}" -f $svc, $_) -ForegroundColor Red
    }
}

# ----- Configurar Windows Update para manual -----
try {
    Set-Service wuauserv -StartupType Manual
    Write-Host "Windows Update configurado para modo manual." -ForegroundColor Green
}
catch {
    Write-Host "Falha ao configurar Windows Update: $($_.Exception.Message)" -ForegroundColor Red
}

# ----- Remover Cortana -----
Write-Host "Removendo Cortana..."
try {
    Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Falha ao remover Cortana: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ----- Remover Microsoft Edge (novo) -----
Write-Host "Removendo Microsoft Edge (novo)..."
try {
    Get-AppxPackage -allusers Microsoft.MicrosoftEdge* | Remove-AppxPackage -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Setup do Edge não encontrado ou falha ao remover, ignorando." -ForegroundColor Yellow
}

# ----- Remover Xbox Game Bar -----
Write-Host "Removendo Xbox Game Bar..."
try {
    Get-AppxPackage -allusers Microsoft.XboxGamingOverlay | Remove-AppxPackage -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Falha ao remover Xbox Game Bar: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ----- Remover outros apps pré-instalados -----
Write-Host "Removendo outros apps pré-instalados..."
$apps = @(
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)
foreach ($app in $apps) {
    try {
        Get-AppxPackage -allusers $app | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host ("Falha ao remover app {0}: {1}" -f $app, $_) -ForegroundColor Yellow
    }
}

Write-Host "Ajustes de privacidade aplicados com sucesso!" -ForegroundColor Green
