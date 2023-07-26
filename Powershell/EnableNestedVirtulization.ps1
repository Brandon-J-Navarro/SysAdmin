#Enable Nested Virtulization
Set-VMProcessor -VMName <#VMName#> -ExposeVirtualizationExtensions $true
