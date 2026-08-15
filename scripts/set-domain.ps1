[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [string]$CurrentDomain = "juandzq.vercel.app"
)

$ErrorActionPreference = "Stop"

function ConvertTo-NormalizedHost {
    param([Parameter(Mandatory = $true)][string]$Value)

    $candidate = $Value.Trim().ToLowerInvariant()
    if (-not $candidate.Contains("://")) {
        $candidate = "https://$candidate"
    }

    $uri = $null
    if (-not [Uri]::TryCreate($candidate, [UriKind]::Absolute, [ref]$uri)) {
        throw "El dominio '$Value' no es valido. Usa un formato como juandzq.com."
    }

    if ($uri.Scheme -ne "https" -or $uri.Port -ne 443 -or $uri.AbsolutePath -ne "/" -or $uri.Query -or $uri.Fragment) {
        throw "Indica solo el dominio, sin rutas, parametros ni puertos. Ejemplo: juandzq.com."
    }

    if ($uri.Host -notmatch '^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$') {
        throw "El dominio '$Value' no tiene un formato de host publico valido."
    }

    return $uri.IdnHost
}

$newHost = ConvertTo-NormalizedHost -Value $Domain
$oldHost = ConvertTo-NormalizedHost -Value $CurrentDomain

if ($newHost -eq $oldHost) {
    throw "El dominio nuevo y el actual son iguales. No hay nada que cambiar."
}

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$relativeFiles = @(
    "index.html",
    "desarrollador-web-colombia/index.html",
    "robots.txt",
    "sitemap.xml",
    "SEO-CHECKLIST.md"
)

$oldBaseUrl = "https://$oldHost"
$newBaseUrl = "https://$newHost"
$utf8NoBom = [Text.UTF8Encoding]::new($false)
$changedFiles = [Collections.Generic.List[string]]::new()

foreach ($relativeFile in $relativeFiles) {
    $filePath = Join-Path $projectRoot $relativeFile
    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        throw "Falta el archivo esperado: $relativeFile"
    }

    $content = [IO.File]::ReadAllText($filePath)
    $updatedContent = $content.Replace($oldBaseUrl, $newBaseUrl)

    if ($updatedContent -ne $content -and $PSCmdlet.ShouldProcess($relativeFile, "Cambiar $oldBaseUrl por $newBaseUrl")) {
        [IO.File]::WriteAllText($filePath, $updatedContent, $utf8NoBom)
        $changedFiles.Add($relativeFile)
    }
}

if ($WhatIfPreference) {
    Write-Host "Simulacion terminada. No se modificaron archivos."
    exit 0
}

if ($changedFiles.Count -eq 0) {
    throw "No se encontro '$oldBaseUrl' en los archivos controlados. Revisa -CurrentDomain."
}

Write-Host "Dominio SEO actualizado a $newBaseUrl en:"
$changedFiles | ForEach-Object { Write-Host "  - $_" }
Write-Host ""
Write-Host "Siguiente paso: agrega $newHost y www.$newHost en Vercel, define uno como principal y redirige el otro."
Write-Host "Despues despliega, verifica /robots.txt y /sitemap.xml, y registra el dominio en Search Console."

