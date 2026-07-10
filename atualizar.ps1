$projeto = "C:\Users\Guilherme Lorin\Documents\PROJETO\carteira-fiis-projeto"
$downloads = "C:\Users\Guilherme Lorin\Downloads\index.html"

if (-Not (Test-Path $downloads)) {
    Write-Host "ERRO: index.html nao encontrado em Downloads!" -ForegroundColor Red
    pause
    exit
}

Copy-Item $downloads "$projeto\index.html" -Force
Write-Host "Arquivo copiado!" -ForegroundColor Green

Set-Location $projeto
git add .
git commit -m "update"
git push

Write-Host "Site atualizado! Aguarde 30 segundos e acesse o site." -ForegroundColor Green
pause
