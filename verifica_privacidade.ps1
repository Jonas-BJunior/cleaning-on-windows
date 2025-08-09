# =========================
# Script para Verificar Ajustes de Privacidade Windows
# =========================

Write-Host "Iniciando verificação de ajustes de privacidade..." -ForegroundColor Cyan

# Define as políticas esperadas (Path do registro, Nome da chave e Valor esperado)
$policies = @{
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" = @{
        "AllowTelemetry" = 0
    }
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" = @{
        "DisableConsumerFeatures" = 1
    }
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" = @{
        "AllowCortana" = 0
    }
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" = @{
        "DisableFileSyncNGSC" = 1
    }
}

foreach ($path in $policies.Keys) {
    foreach ($name in $policies[$path].Keys) {
        try {
            $value = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction Stop
            $expected = $policies[$path][$name]
            if ($value -eq $expected) {
                Write-Host "OK: '$name' está configurado corretamente em '$path'." -ForegroundColor Green
            }
            else {
                Write-Warning "ALERTA: '$name' NÃO está configurado corretamente em '$path'. Esperado: $expected, Atual: $value"
            }
        }
        catch {
            Write-Warning ("Erro ao verificar '${name}' em '${path}': $_")
        }
    }
}

# Verificar se serviços de telemetria estão parados e desabilitados
$services = @("diagtrack", "dmwappushservice")

foreach ($svc in $services) {
    try {
        $svcObj = Get-Service -Name $svc -ErrorAction Stop
        if ($svcObj.Status -eq 'Stopped' -and $svcObj.StartType -eq 'Disabled') {
            Write-Host "OK: Serviço '$svc' está parado e desabilitado." -ForegroundColor Green
        }
        else {
            Write-Warning "ALERTA: Serviço '$svc' não está na condição esperada. Status: $($svcObj.Status), Tipo de Inicialização: $($svcObj.StartType)"
        }
    }
    catch {
        Write-Warning ("Erro ao verificar o serviço '$svc': $_")
    }
}

# Verificar se domínios de telemetria estão bloqueados no arquivo hosts
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

try {
    $hostsContent = Get-Content -Path $hostsPath -ErrorAction Stop
    $missingDomains = @()
    foreach ($domain in $telemetryDomains) {
        $pattern = "^0\.0\.0\.0\s+$domain$"
        if (-not ($hostsContent -match $pattern)) {
            $missingDomains += $domain
        }
    }

    if ($missingDomains.Count -eq 0) {
        Write-Host "OK: Todos os domínios de telemetria estão bloqueados no hosts." -ForegroundColor Green
    }
    else {
        Write-Warning "ALERTA: Os seguintes domínios NÃO estão bloqueados no hosts:`n - $($missingDomains -join "`n - ")"
    }
}
catch {
    Write-Warning ("Erro ao ler o arquivo hosts: $_")
}

Write-Host "Verificação finalizada." -ForegroundColor Cyan
