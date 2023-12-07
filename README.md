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

### GetApplicationInformation.ps1

### RemoveGuestAccounts.ps1

### GetRoleAssignments.ps1
