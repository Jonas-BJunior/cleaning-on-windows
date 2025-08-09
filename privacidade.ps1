# =========================
# Script de Privacidade Windows
# =========================

Write-Host "Iniciando ajustes de privacidade..." -ForegroundColor Green

# ----- Desativar Telemetria -----
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Type DWord -Value 0

# ----- Desativar Experiências do Consumidor -----
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableConsumerFeatures -Type DWord -Value 1

# ----- Desativar Cortana -----
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -Type DWord -Value 0

# ----- Desativar OneDrive -----
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name DisableFileSyncNGSC -Type DWord -Value 1

# ----- Bloquear domínios de telemetria no hosts -----
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$telemetryDomains = @(
    "vortex.data.microsoft.com",
    "telecommand.telemetry.microsoft.com",
    "telemetry.microsoft.com",
    "oca.telemetry.microsoft.com",
    "sqm.telemetry.microsoft.com",
    "watson.microsoft.com",
    "reports.wes.df.telemetry.microsoft.com"
)

Write-Host "Atualizando arquivo hosts..."

# Ler conteúdo atual do hosts
$hostsContent = Get-Content -Path $hostsPath -ErrorAction SilentlyContinue

if ($hostsContent) {
    $updated = $false
    foreach ($domain in $telemetryDomains) {
        $pattern = "^0\.0\.0\.0\s+$domain$"
        if (-not ($hostsContent -match $pattern)) {
            Add-Content -Path $hostsPath "0.0.0.0 $domain"
            $updated = $true
        }
    }
    if ($updated) {
        Write-Host "Domínios adicionados no hosts."
    } else {
        Write-Host "Domínios de telemetria já bloqueados no hosts."
    }
} else {
    Write-Warning "Não foi possível ler o arquivo hosts. Execute o script como Administrador."
}

# ----- Desativar Serviços de Telemetria -----
$services = @("diagtrack", "dmwappushservice")

foreach ($svc in $services) {
    Write-Host "Parando e desabilitando serviço: $svc"
    try {
        Stop-Service -Name $svc -Force -ErrorAction Stop
        Set-Service -Name $svc -StartupType Disabled
        Write-Host "Serviço $svc desativado com sucesso." -ForegroundColor Green
    } catch {
        $e = $_
        Write-Warning ("Falha ao modificar serviço " + $svc + ": " + $e.Exception.Message)
    }
}

# ----- Configurar Windows Update para manual -----
try {
    Set-Service wuauserv -StartupType Manual
    Write-Host "Windows Update configurado para modo manual." -ForegroundColor Green
} catch {
    $e = $_
    Write-Warning ("Falha ao configurar Windows Update: " + $e.Exception.Message)
}

# ----- Remover Cortana -----
Write-Host "Removendo Cortana..."
try {
    Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppxPackage -ErrorAction Stop
    Write-Host "Cortana removida com sucesso."
} catch {
    $e = $_
    Write-Warning ("Falha ao remover Cortana: " + $e.Exception.Message)
}

# ----- Remover Microsoft Edge (Legacy) -----
Write-Host "Removendo Microsoft Edge (legacy)..."
try {
    Get-AppxPackage -AllUsers Microsoft.MicrosoftEdge | Remove-AppxPackage -ErrorAction Stop
    Write-Host "Microsoft Edge (legacy) removido com sucesso."
} catch {
    Write-Warning "Setup do Edge não encontrado, ignorando remoção."
}

# ----- Remover Xbox Game Bar -----
Write-Host "Removendo Xbox Game Bar..."
try {
    Get-AppxPackage -AllUsers Microsoft.XboxGamingOverlay | Remove-AppxPackage -ErrorAction Stop
    Write-Host "Xbox Game Bar removida com sucesso."
} catch {
    $e = $_
    Write-Warning ("Falha ao remover Xbox Game Bar: " + $e.Exception.Message)
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
        $pkg = Get-AppxPackage -AllUsers $app
        if ($pkg) {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "App $app removido com sucesso."
        }
    } catch {
        $e = $_
        Write-Warning ("Falha ao remover app " + $app + ": " + $e.Exception.Message)
    }
}

Write-Host "Ajustes de privacidade aplicados com sucesso!" -ForegroundColor Green
