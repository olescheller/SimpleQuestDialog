Remove-Item -Recurse $PSScriptRoot\..\target
New-Item $PSScriptRoot\..\target -ItemType Directory
New-Item $PSScriptRoot\..\target\$(Write-Output (Split-Path $PSScriptRoot\.. -Leaf)) -ItemType Directory
Copy-Item $PSScriptRoot\..\src\* -Destination $PSScriptRoot\..\target\$(Write-Output (Split-Path $PSScriptRoot\.. -Leaf))\
Compress-Archive -Path $PSScriptRoot\..\target\$(Write-Output (Split-Path $PSScriptRoot\.. -Leaf))\ -DestinationPath $PSScriptRoot\..\target\$(Write-Output (Split-Path $PSScriptRoot\.. -Leaf)).zip