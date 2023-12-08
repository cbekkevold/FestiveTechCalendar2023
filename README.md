# FestiveTechCalendar2023

Scripts for Christmas Cleaning in Entra ID, hope this helps you keep Entra ID clean! 🧹

If you're not familiar with Microsoft Graph PowerShell SDK, you can read more about it here: [Getting started with Microsoft PowerShell Graph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0)

And if you have old scripts using the Azure AD or MSOnline modules you can easily convert them to Microsoft Graph PowerShell, using this cmdlet mapping list: [Cmdlet Mapping List](https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0)

If you don't allready have the module installed, you can use these to get both  the production and beta modules:

```powershell
Install-Module Microsoft.Graph

Install-Module Microsoft.Graph.Beta
```

## Scripts in this repository

You can run all scripts by default, no changes needed if you accept my conditions.
Scopes are set for every script, but you might need to have administrator role(s) too.

### GetApplicationInformation.ps1

This script is built on Microsofts own example: [Export app registrations with expiring secrets and certificates](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/scripts/powershell-export-apps-with-expiring-secrets). I wanted more information, so I have rewrited it to fit my needs. And you can also use this information to maybe clean up som old applications that are not used anymore, or not working because of expired secrets/certificates. My default is to check for secrets or certificates that expire within the next 60 days, but you can change this to whatever you want. Warning: because of the sign-in logs this script uses some time to finish!

Explanation for columns in exported Excel-file:

- ApplicationName: Display name of application in Entra ID
- ApplicationID: Application Id / Client Id of the application
- Expired secrets/soon to expire:
  - True: One or more secrets are about to expire
  - False: No secrets are about to expire
  - "No secrets found": Application don't have secrets.
- Expired certs/soon to expire:
  - True: One or more secrets are about to expire
  - False: No secrets are about to expire
  - "No secrets found": Application don't have secrets.
- Owner: User principal name for owner(s). "No owner" if no owners are found.
- Created: Creation time for the application
- PublisherDomain: domain the app is published to.
- SignInAudience: Who can use the application? Will be one of these supported account types:
  - AzureADMyOrg
  - AzureADMultipleOrgs
  - AzureADandPersonalMicrosoftAccount
- LastSignIn: Date time of last sign in, or "N/A" if there are no signings

### RemoveGuestAccounts.ps1

This script removes guest accounts with a few conditions.

- Guests with pending invitation: if the invitation was sent more than 90 days ago, it will be deleted.
- Guest accounts with accepted invitations: will be deleted if the user is not in any groups and their last sign in was more than 90 days ago.

### GetRoleAssignments.ps1

This script gets role assignments, both eligible active and for groups. I collect information and export it to an excel-file.
I think i gives a nice overview on the role assignments in the tenant.

Explanation for columns in exported Excel-file:
Eligible and active role assignments:

- RoleName: Name of the role
- PrincipalName: Name of the user, group or serviceprincipal the role is assigned to
- PrincipalType: user/group/serviceprincipal
- AssignmentType: Eligible/Eligible (Permanent)/Assigned/Assigned (Permanent).
- OnPremSynced: Only for the users, if the account is synced from on-prem AD.
- RoleStartDate: Start date of the assignment.
- RoleEndDate: End date of the assignement (if not permanent)
- UsingMFA: Only for the users, if the user har registered and are using MFA.

Group Assignments:

- UserPrincipalName: UPN of the user/memeber assigned to the role
- Group: Name of the group.
- RoleStartDate: Start date of the assignment.
- RoleEndDate: End date of the assignement.
