$foundCert = Test-Certificate -Cert Cert:\CurrentUser\my\43eb601ecc35ed5263141d4dc4aff9c77858451c -User
if(!$foundCert)
{
    Write-Host "Certificate doesn't exist. Exit."
    exit
}

Write-Host "Certificate found. Sign the assemblies."
$signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64\signtool.exe"
foreach ($line in Get-Content .\sign.txt) {
    & $signtool sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /a .\bin\$line | Write-Debug
}

Write-Host "Verify digital signature."
foreach ($line in Get-Content .\sign.txt) {
    & $signtool verify /pa /q .\bin\$line 2>&1 | Write-Debug
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host ".\bin\$line is not signed. Exit."
        exit $LASTEXITCODE
    }

    Write-Host ".\bin\$line is signed."
}

Write-Host "Verification finished."

Remove-Item -Path .\*.nupkg
$nuget = "f:\nuget.exe"
& $nuget update /self | Write-Debug
foreach ($line in Get-Content .\nuspec.txt) {
    & $nuget pack $line
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host "NuGet package is not generated. Exit."
        exit $LASTEXITCODE
    }
}

Write-Host "Sign NuGet packages."
& $nuget sign *.nupkg -CertificateSubjectName "Yang Li" -Timestamper http://timestamp.digicert.com | Write-Debug
& $nuget verify -All *.nupkg | Write-Debug
if ($LASTEXITCODE -ne 0)
{
    Write-Host "NuGet package is not signed. Exit."
    exit $LASTEXITCODE
}

Write-Host "Verification finished."
