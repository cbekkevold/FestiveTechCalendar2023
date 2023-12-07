Connect-MgGraph -Scopes User.Read.All

$DaysBack = $(Get-Date).AddDays(-90)

# Deleting guest accounts where the invitation is sent more then 90 days ago, and they've never accepted it.
$PendingGuestAccounts = Get-MgUser -All -Filter "userType eq 'Guest' and externalUserState eq 'PendingAcceptance'" -Property id, displayname, userPrincipalName, mail, externalUserState, createdDateTime 

foreach ($PendingGuest in $PendingGuestAccounts) {
    if ($PendingGuest.CreatedDateTime -le $DaysBack) {
        Write-Host "Delete User: $($PendingGuest.UserPrincipalName). Created: $($PendingGuest.CreatedDateTime)" -ForegroundColor Green
        Remove-MgUser -UserId $PendingGuest.Id 
    }
    else {
        Write-Host "Skip User: $($PendingGuest.UserPrincipalName). Created: $($PendingGuest.CreatedDateTime)" -ForegroundColor Yellow
    }
}

# Deleting guest accounts where the invitation is accepted, but the user has not signed in (interactive) for the past 90 days, and they are not member of anything (other than dynamic group "All users")
$AcceptedGuestAccounts = Get-MgUser -All -Filter "userType eq 'Guest' and externalUserState eq 'Accepted'" -Property id, displayname, userPrincipalName, mail, signinActivity, externalUserState, createdDateTime 

foreach ($AcceptedGuest in $AcceptedGuestAccounts) {
    $MemberOf = Get-MgUserMemberOf -UserId $AcceptedGuest.Id -Property id
    if (($AcceptedGuest.SignInActivity.LastSignInDateTime -le $DaysBack) -and ($MemberOf.Count -le 1)) {
        Write-Host "Delete User: $($AcceptedGuest.UserPrincipalName). Created: $($AcceptedGuest.CreatedDateTime)" -ForegroundColor Green
        Remove-MgUser -UserId $AcceptedGuest.Id
    }
    else {
        Write-Host "Skip User: $($AcceptedGuest.UserPrincipalName). Created: $($AcceptedGuest.CreatedDateTime)." -ForegroundColor Yellow
    }
}
