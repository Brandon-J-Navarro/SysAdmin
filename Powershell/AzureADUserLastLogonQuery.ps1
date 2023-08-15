# Azure AD User Last Logon Query

Install-Module AzureADPreview
Import-Module AzureADPreview

# Set Environment if needed (-AzureEnvironmentName AzureUSGovernment)
Connect-AzureAD 

# CSV with "userPrincipalName" as column name and users UPN in the rows
$userList = Import-Csv .\Downloads\AzUsersUPN.csv

foreach ($user in $userList) {
    Start-Sleep -Seconds 2
    $auditInfo = Get-AzureADAuditSignInLogs -Filter "startsWith(userPrincipalName,'$($user.UserPrincipalName)')" -Top 1
    [PSCustomObject] @{
        Username    = $auditInfo.UserPrincipalName
        LastSignIn  = $auditInfo.CreatedDateTime
        Application = $auditInfo.AppDisplayName
    } | Export-Csv .\Downloads\AuditResults.csv -Append -NoTypeInformation
}
