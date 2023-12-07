Connect-MgGraph -Scopes AuditLog.Read.All, Application.Read.All
$DaysToExpiration = "60"
$FilePath = "<YOURPATHHERE>\EntraIDApplications.xlsx"
$Now = Get-Date
$Report = @()
$AppCounter = 1
$Applications = Get-MgApplication -All
Write-Host "Found $($Applications.Count) applications!" -ForegroundColor Green

foreach ($App in $Applications) {
    Write-Host "Working with application #$($AppCounter) of $($Applications.Count)"
    $AppDisplayName = $App.DisplayName
    $AppID = $App.Id
    $ApplicationID = $App.AppId

    if ($App.AppOwnerOrganizationId -eq $tenantID) {
        $CreatedDateTime = $App.CreatedDateTime
        $Secrets = $App.PasswordCredentials
        $Certificates = $App.KeyCredentials
        if ($Secrets.Count -ne 0) {
            foreach ($Secret in $Secrets) {
                $RemainingDays = $Secret.EndDateTime - $Now | Select-Object -ExpandProperty Days
                if ($RemainingDays -le $DaysToExpiration) {
                    $ExpiredSecrets = $true
                    continue
                } else { $ExpiredSecrets = $false }
            } 
        } else { $ExpiredSecrets = "No secrets found"}
        if ($Certs.Count -ne 0) {
            foreach ($Certificate in $Certificates) {
                $RemainingDays = $Certificate.EndDateTime - $Now | Select-Object -ExpandProperty Days
                if ($RemainingDays -le $DaysToExpiration) {
                    $ExpiredCertificates = $true
                    continue
                } else { $ExpiredCertificates = $false }  
            } 
        } else {$ExpiredCertificates = "No certificates found"}

        $Owner = Get-MgApplicationOwner -ApplicationId $AppID
        $Username = $Owner.AdditionalProperties.userPrincipalName -join ','

        if ($null -eq $Username) {
            $Username = @(
                "Application:"
                $Owner.AdditionalProperties.displayName
            ) -join ' '
        }
        if ($null -eq $Owner.AdditionalProperties.displayName) {
            $Username = "No Owner"
        }
    }
    
    $LastSignIn = Get-MgAuditLogSignIn -Filter "appId eq '$ApplicationID'" -Top 1 
    if ($LastSignIn) {
        $LastUsed = $LastSignIn.CreatedDateTime
    }
    else { $LastUsed = "N/A" }

    $Report += [PSCustomObject]@{
        'ApplicationName'                   = $AppDisplayName
        'ApplicationID'                     = $ApplicationID
        'Expired secrets/soon to expire'    = $ExpiredSecrets
        'Expired certs/soon to expire'      = $ExpiredCertificates
        'Owner'                             = $Username
        'Created'                           = $CreatedDateTime
        'PublisherDomain'                   = $App.PublisherDomain
        'SignInAudience'                    = $App.SignInAudience
        'LastSignIn'                        = $LastUsed
    }
    $AppCounter++
}

$Report | Sort-Object ApplicationName | Export-Excel -Path $FilePath -AutoSize -TableName "EntraIDApps" -WorksheetName "Entra ID Apps"
Write-Host "Done! Applications exported to $FilePath" -ForegroundColor Green