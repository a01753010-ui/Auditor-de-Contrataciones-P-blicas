# Arranca el servidor de desarrollo usando el Node portátil de .node (no requiere Node instalado).
# Uso:  .\dev.ps1            -> npm run dev
#       .\dev.ps1 build      -> npm run build
#       .\dev.ps1 install    -> npm install
#       .\dev.ps1 backend    -> npm run dev contra el backend Flask (http://localhost:5000)
#                               en vez de la simulación; arráncalo antes con scripts\backend_prueba.ps1
param([string]$Comando = 'dev')

$node = Get-ChildItem "$PSScriptRoot\.node" -Directory -Filter 'node-*' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($node) { $env:Path = "$($node.FullName);$env:Path" }

Set-Location $PSScriptRoot
if ($Comando -eq 'backend') {
    # Vite toma las variables VITE_* del entorno; solo afecta a esta ejecución.
    $env:VITE_USE_MOCK = 'false'
    $Comando = 'dev'
}
if ($Comando -eq 'install') { npm install } else { npm run $Comando }
