Remove-Item -Recurse $PSScriptRoot\..\target
New-Item $PSScriptRoot\..\target -ItemType Directory
Compress-Archive -Path $PSScriptRoot\..\src\* -DestinationPath $PSScriptRoot\..\target\$(Write-Output (Split-Path .. -Leaf)).zip