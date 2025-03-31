# Config
$adminUPN = "famoll@mollcgc.com"
$groupEmail = "mcal@franciscomoll.onmicrosoft.com"
$clientId = "1cb3a24b-d964-47d5-8cf2-33ea97d2b0f8"
$tenantId = "fb7e002b-934b-4435-8358-23195e6bf22d"
$siteUrl = "https://franciscomoll.sharepoint.com/sites/mcal"
$ownerUsers = @(
    "fmoll@mollcgc.com",
    "agnes.moll@mollcgc.com"
)
$contributorUsers = @(
    "isidro.ramirez@mollcgc.com"
)

# Exchange: Group Membership + Calendar Permissions
Write-Host "`n[+] Connecting to Exchange Online..."
Connect-ExchangeOnline -UserPrincipalName $adminUPN
# Add Owners
foreach ($owner in $ownerUsers) {
    try {
        Add-UnifiedGroupLinks -Identity $groupEmail -LinkType Members -Links $owner -ErrorAction Stop
        Write-Host "Added $owner as a member of the group."
    } catch {
        Write-Warning "Could not add $owner as member: $_"
    }
    try {
        Add-UnifiedGroupLinks -Identity $groupEmail -LinkType Owners -Links $owner -ErrorAction Stop
        Write-Host "Added $owner as an owner of the group."
    } catch {
        Write-Warning "Could not add $owner as owner: $_"
    }
}

# Add Contributors and Grant Calendar Access
$calendarIdentity = "${groupEmail}:\Calendar"
foreach ($user in $contributorUsers) {
    try {
        Add-UnifiedGroupLinks -Identity $groupEmail -LinkType Members -Links $user -ErrorAction Stop
        Write-Host "Added $user as a member of the group."
    } catch {
        Write-Warning "Could not add $user as a member: $_"
    }
    try {
        Set-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Reviewer -ErrorAction Stop
        Write-Host "Set reviewer permissions for $user on group calendar."
    } catch {
        try {
            Add-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Reviewer
            Write-Host "Added reviewer permissions for $user on group calendar."
        } catch {
            Write-Error "Could not set calendar permissions for ${user}: $_"
        }
    }
}
# SharePoint: Grant Contribute Access
Write-Host "`n[+] Connecting to SharePoint via PnP..."
try {
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $tenantId -Interactive
    Write-Host "Connected to SharePoint."
} catch {
    Write-Error "Failed to connect to SharePoint: $_"
    return
}
foreach ($user in $contributorUsers) {
    try {
        Set-PnPWebPermission -User $user -AddRole "Contribute"
        Write-Host "Granted contribute permissions to ${user}."
    } catch {
        Write-Warning "Could not grant contribute permissions to ${user}: $_"
    }
}
# Restrict News Posts
Write-Host "`n[+] Locking down Site Pages..." -ForegroundColor Cyan
try {
    Set-PnPListPermssion -Identity "Site Pages" -BreakRoleInheritance -CopyRoleAssignments:$true -ClearSubscopes:$true
    Write-Host "Broke permission inheritance on Site Pages." -ForegroundColor Yellow
} catch {
    Write-Warning "Could not break inheritance on Site Pages: $_"
}
foreach ($user in $contributorUsers) {
    try {
        Remove-PnPListItemPermission -List "Site Pages" -User $user -Force
        Write-Host "Removed ${user}'s edit access to Site Pages." -ForegroundColor Green
    } catch {
        Write-Warning "Could not remove access for ${user}: $_"
    }
    try {
        Add-PnPListItemPermission -List "Site Pages" -User $user -AddRole "Read"
        Write-Host "Granted read access to Site Pages for ${user}."
    } catch {
        Write-Warning "Could not grant read access to ${user}: $_"
    }
}

# # Attempt to get group site URL
# try {
#     $siteUrl = "https://franciscomoll.sharepoint.com/sites/mcal"
#     Write-Host "Retrieved SharePoint site URL: $siteUrl"
# } catch {
#     Write-Warning "Could not retrieve site URL for group $groupEmail. Please confirm group exists."
#     return
# }

# # Reconnect to site
# Connect-PnPOnline -Url $siteUrl -Interactive

# # Grant Contribute permissions
# foreach ($user in $contributorUsers) {
#     try {
#         Set-PnPWebPermission -User $user -AddRole "Contribute"
#         Write-Host "Granted Contribute permissions to $user on SharePoint site."
#     } catch {
#         Write-Warning "Could not grant Contribute permissions to ${user}: $_"
#     }
# }

# # module check
# Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue
# Import-Module PnP.PowerShell -ErrorAction SilentlyContinue

# # connect to exchange
# Connect-ExchangeOnline -UserPrincipalName famoll@mollcgc.com

# # group email
# $group = "mcal@franciscomoll.onmicrosoft.com"

# # new owners
# $ownerUsers = @(
#     "fmoll@mollcgc.com",
#     "agnes.moll@mollcgc.com"
# )

# # new members
# $contributorUsers = @(
#     "isidro.ramirez@mollcgc.com"
# )

# # add owner users 
# foreach ($user in $ownerUsers) {
#     try {
#         Add-UnifiedGroupLinks -Identity $group -LinkType Members -Link $user -ErrorAction Stop
#         Write-Host "Added $user as a member of the group."
#     }
#     catch {
#         Write-Warning "Could not add $user as a member: $_"
#     }

#     try {
#         Add-UnifiedGroupLinks -Identity $group -LinkType Owners -Links $user -ErrorAction Stop
#         Write-Host "Added $user as an owner of the group."
#     }
#     catch {
#         Write-Warning "Failed to add $user as an owner: $_"
#     }
# }

# # add contributors as members, grant calendar access
# $calendarIdentity = "${group}:\Calendar"

# foreach ($user in $contributorUsers) {
#     try {
#         Add-UnifiedGroupLinks -Identity $group -LinkType Members -Links $user -ErrorAction Stop
#         Write-Host "Added $user as a member of the group."
#     }
#     catch {
#         Write-Warning "Could not add $user as member: $_"
#     }

#     try {
#         Set-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Reviewer
#         Write-Host "Added reviewer permission for $user on the group calendar."
#     }
#     catch {
#         try {
#             Add-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Reviewer
#             Write-Host "Added reviewer permission for $user on the group calendar."
#         }
#         catch {
#             Write-Error "Could not set calendar permission for ${user}: $_"
#         }
#     }
# }

# # modify member sharepoint access
# # connection details
# Connect-PnPOnline -Scopes "Group.Read.All", "Sites.ReadWrite.All" -Interactive

# $siteUrl = (Get-PnPMicrosoft365Group -Identity $group).SiteUrl

# #reconnect directly to sharepoint
# Connect-PnPOnline -Url $siteUrl -Interactive

# #grant contribute permissions
# foreach ($user in $contributorUsers) {
#     try {
#         Set-PnPWebPermission -User $user -AddRole "Contribute"
#         Write-Host "Granted contribute permissions to $user on Sharepoint."
#     }
#     catch {
#         Write-Warning "Could not grant contribute permissions to ${user}: $_"
#     }
# }