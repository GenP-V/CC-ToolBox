# Guide available at https://www.reddit.com/r/GenP/

$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadURL = 'https://dank-site.onrender.com/GenP/cc-toolbox-cmd'

$rand = Get-Random -Maximum 99999999
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\CC-ToolBox_$rand.cmd" } else { "$env:TEMP\CC-ToolBox$rand.cmd" }

try {
    $response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing
}
catch {
    Write-Error "Failed to download CC-ToolBox.cmd from $DownloadURL"
    exit 1
}

$ScriptArgs = "$args "
$prefix = "@REM $rand `r`n"
$content = $prefix + $response
Set-Content -Path $FilePath -Value $content

Start-Process $FilePath $ScriptArgs -Wait

$FilePaths = @("$env:TEMP\CC-ToolBox*.cmd", "$env:SystemRoot\Temp\CC-ToolBox*.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
