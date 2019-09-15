$nuget = "f:\nuget.exe"
& $nuget update /self | Write-Debug
foreach ($file in Get-ChildItem . -Filter *.nupkg) {
    & $nuget push $file -Source https://www.nuget.org/api/v2/package
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host "NuGet package is not published. Exit."
        exit $LASTEXITCODE
    }
}
