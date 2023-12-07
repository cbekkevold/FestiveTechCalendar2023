Connect-MgGraph -Scopes PrivilegedAssignmentSchedule.Read.AzureADGroup, RoleEligibilitySchedule.Read.Directory, RoleAssignmentSchedule.Read.Directory
$FilePath = "<YOURPATHHERE>\RoleAssignments.xlsx"
$AllAssignments = @()
$AllGroupAssignments = @()
$PimGroups = @()
$RoleDefinitions = Get-MgRoleManagementDirectoryRoleDefinition 

# PIM : Eligible assignments
Write-Host "Working eith eligible assignments!"
$EligibleAssignments = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance
foreach ($assignment in $EligibleAssignments) {
    $MFA = "N/A"
    $SyncStatus = "N/A"
    $RoleName = $($RoleDefinitions | Where-Object { $_.Id -eq $assignment.RoleDefinitionId }).DisplayName
    $Object = Get-MgDirectoryObject -DirectoryObjectId $assignment.PrincipalId -ErrorAction Ignore

    switch ($Object.AdditionalProperties.'@odata.type') {
        "#microsoft.graph.user" { $ObjectType = "User" }
        "#microsoft.graph.group" { $ObjectType = "Group" }
        "#microsoft.graph.servicePrincipal" { $ObjectType = "ServicePrincipal" }
        Default { $ObjectType = $Object.AdditionalProperties.'@odata.type' }
    }
    if ($ObjectType -eq "User") {
        $AuthMethods = Get-MgUserAuthenticationMethod -UserId $Object.AdditionalProperties.userPrincipalName
        if ($AuthMethods.Count -gt 0) {
            $MFA = $true
        } else { $MFA = $false }
        if ($null -ne $Object.AdditionalProperties.onPremisesLastSyncDateTime) {
            $SyncStatus = $true
        } else { $SyncStatus = $false }
    }
    elseif ($ObjectType -eq "Group") {
        $PimGroups += $Object.Id
    }
    
    if (-not $assignment.EndDateTime) {
        $AssignmentType = "Eligible (Permanent)"
    } else { $AssignmentType = "Eligible" }

    $tempObject = [pscustomobject]@{
        RoleName       = $RoleName
        PrincipalName  = $Object.AdditionalProperties.displayName
        PrincipalType  = $ObjectType
        AssignmentType = $AssignmentType
        OnPremSynced   = $SyncStatus
        RoleStartDate  = $assignment.StartDateTime
        RoleEndDate    = $assignment.EndDateTime
        UsingMFA       = $MFA
    }
    $AllAssignments += $tempObject
}

# PIM : Active assignments
Write-Host "Working with active assignments!"
$ActiveAssignments = Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance 
foreach ($assignment in $ActiveAssignments) {
    $MFA = "N/A"
    $SyncStatus = "N/A"
    if ($assignment.AssignmentType -ne "Activated") {
        $RoleName = $($RoleDefinitions | Where-Object { $_.Id -eq $assignment.RoleDefinitionId }).DisplayName
        $Object = Get-MgDirectoryObject -DirectoryObjectId $assignment.PrincipalId -ErrorAction Ignore

        switch ($Object.AdditionalProperties.'@odata.type') {
            "#microsoft.graph.user" { $ObjectType = "User" }
            "#microsoft.graph.group" { $ObjectType = "Group" }
            "#microsoft.graph.servicePrincipal" { $ObjectType = "ServicePrincipal" }
            Default { $ObjectType = $Object.AdditionalProperties.'@odata.type' }
        }
        if ($ObjectType -eq "User") {
            $AuthMethods = Get-MgUserAuthenticationMethod -UserId $Object.AdditionalProperties.userPrincipalName
            if ($AuthMethods.Count -gt 0) {
                $MFA = $true
            } else { $MFA = $false }
            if ($null -ne $Object.AdditionalProperties.onPremisesLastSyncDateTime) {
                $SyncStatus = $true
            } else { $SyncStatus = $false }
        }
        elseif ($ObjectType -eq "Group") {
            $PimGroups += $Object.Id
        }
        if (-not $assignment.EndDateTime) {
            $AssignmentType = "Assigned (Permanent)" 
        } else { $AssignmentType = "Assigned" }

        $tempObject = [pscustomobject]@{
            RoleName       = $RoleName
            PrincipalName  = $Object.AdditionalProperties.displayName
            PrincipalType  = $ObjectType
            AssignmentType = $AssignmentType
            OnPremSynced   = $SyncStatus
            RoleStartDate      = $assignment.StartDateTime
            RoleEndDate        = $assignment.EndDateTime
            UsingMFA       = $MFA
        }
        $AllAssignments += $tempObject
    }
}

# PIM : Group Assignments
Write-Host "Working with group assignments!"
foreach ($group in $PimGroups) {
    $groupAssignment = Get-MgIdentityGovernancePrivilegedAccessGroupAssignmentScheduleInstance -Filter "groupId eq '$group'"
    foreach ($member in $groupAssignment) {
        $thisMember = Get-MgUser -User $member.PrincipalId
        $thisGroup = Get-MgGroup -GroupId $group

        $tempObject = [pscustomobject]@{
            UserPrincipalName = $thisMember.UserPrincipalName
            Group             = $thisGroup.DisplayName
        }
        $AllGroupAssignments += $tempObject
    }
}

$AllAssignments | Export-Excel -Path $FilePath -WorksheetName "PIM Assignments" -TableName "PIMAssignments" -AutoSize
$AllGroupAssignments | Export-Excel -Path $FilePath -WorksheetName "PIM Group Assignments" -TableName "PIMGroupAssignments" -AutoSize

Write-Host "Done! Files exported to: $FilePath" -ForegroundColor Green