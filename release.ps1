# 发布一个新版本：把 src/app.html 打包成 v<编号>/index.html，旧版本原样保留。
# 用法：.\release.ps1 -Note "这一版改了什么"            （编号自动 +1）
#       .\release.ps1 -Source old.html -Version 1 -Note "..."  （补发指定编号）
param(
  [string]$Note = "",
  [string]$Source = "src\app.html",
  [int]$Version = 0
)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$utf8 = New-Object Text.UTF8Encoding $false

$listPath = "versions.json"
$list = @()
if (Test-Path $listPath) { $list = @(([IO.File]::ReadAllText("$PWD\$listPath", $utf8) | ConvertFrom-Json) | ForEach-Object { $_ }) }
if ($Version -le 0) { $Version = 1; foreach ($v in $list) { if ($v.v -ge $Version) { $Version = $v.v + 1 } } }
$dir = "v$Version"
if (Test-Path $dir) { throw "$dir 已经存在。旧版本不能覆盖，请换一个编号。" }

$head = '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><meta name="theme-color" content="#e8668f"><style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style></head><body>'
$body = [IO.File]::ReadAllText((Resolve-Path $Source), $utf8)
New-Item -ItemType Directory $dir | Out-Null
[IO.File]::WriteAllText("$PWD\$dir\index.html", $head + "`n" + $body + "`n</body></html>`n", $utf8)

$list += [pscustomobject]@{ v = $Version; date = (Get-Date -Format 'yyyy-MM-dd'); note = $Note }
$list = @($list | Sort-Object v)
[IO.File]::WriteAllText("$PWD\$listPath", (ConvertTo-Json -InputObject $list -Depth 3), $utf8)
Write-Output "已发布 $dir"
