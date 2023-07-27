<#
Released under MIT License

Copyright (c) 2023 Brandon J. Navarro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

#PasswordLastSet
get-aduser -filter {Enabled -eq $True} -SearchScope OneLeve -SearchBase ("OU=[ORGANIZATIONALUNIT],OU=[ORGANIZATIONALUNIT],DC=[DOMAIN],DC=[DOMAIN],DC=com") -properties passwordlastset, passwordneverexpires | Format-Table Name, passwordlastset, Passwordneverexpires

#ExparationDate
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -SearchScope OneLeve -SearchBase ("OU=[ORGANIZATIONALUNIT],OU=[ORGANIZATIONALUNIT],DC=[DOMAIN],DC=[DOMAIN],DC=com") -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

#PasswordLastSetGreaterThan90Days
Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -SearchScope OneLeve -SearchBase ("OU=[ORGANIZATIONALUNIT],OU=[ORGANIZATIONALUNIT],DC=[DOMAIN],DC=[DOMAIN],DC=com") -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -lt (Get-Date).adddays(-90)} | Select-Object Name,SamAccountName,PasswordLastSet

#ExparationDateLessThan30DaysAWay
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -SearchScope OneLeve -SearchBase ("OU=[ORGANIZATIONALUNIT],OU=[ORGANIZATIONALUNIT],DC=[DOMAIN],DC=[DOMAIN],DC=com") -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname",@{Name = "ExparationDate"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Where-Object {$_.ExparationDate -ge (Get-Date).Date -and $_.ExparationDate -le (Get-Date).Date.AddDays(30)}

#ExparationDateLessThan30DaysAWay
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -SearchScope OneLeve -SearchBase ("OU=[ORGANIZATIONALUNIT],OU=[ORGANIZATIONALUNIT],DC=[DOMAIN],DC=[DOMAIN],DC=com") -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname",@{Name = "ExparationDate"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Where-Object {$_.ExparationDate -le (Get-Date).Date.AddDays(30)}

#LockedOutAccounts
Get-ADUser -filter {Enabled -eq $True} -SearchScope OneLeve -SearchBase ("OU=[ORGANIZATIONALUNIT],OU=[ORGANIZATIONALUNIT],DC=[DOMAIN],DC=[DOMAIN],DC=com") -Properties "Displayname","LockedOut" | Select-Object -Property "Displayname","LockedOut" | Where-Object LockedOut -EQ $True
