# setPermissionsv3.ps1

# Config
$adminUPN = "famoll@mollcgc.com"
$groupEmail = "mcal@franciscomoll.onmicrosoft.com"
$calendarIdentity = "mcal@franciscomoll.onmicrosoft.com:\Calendar"

# URL = "https://franciscomoll.sharepoint.com/sites/mcal"

$ownerUsers = @(
    "fmoll@mollcgc.com",
    "agnes.moll@mollcgc.com"
)
$contributorUsers = @(
    "isidro.ramirez@mollcgc.com"
)

# Ensure PnP.PowerShell module is loaded
Import-Module "$HOME\Documents\PowerShell\Modules\PnP.PowerShell\PnP.PowerShell.psd1" -ErrorAction Stop

# Connect to Exchange
Write-Host "`n[+] Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -UserPrincipalName $adminUPN

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

# Add contributors and calendar access
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
            Write-Host "Added reviewer permissions for $user on group calendar"
        } catch {
            Write-Error "Could not set calendar permissions for ${user}: $_"
        }
    }
}

# Connect to SharePoint
Write-Host "`n[+] Connecting to SharePoint via PnP..." -ForegroundColor Cyan
try {
    Connect-PnPOnline -ClientId "1cb3a24b-d964-47d5-8cf2-33ea97d2b0f8" -Tenant "franciscomoll.onmicrosoft.com" -Interactive
    Write-Host "Connected to SharePoint." -ForegroundColor Green
} catch {
    Write-Error "Failed to connect to SharePoint: $_"
    return
}

# Grant Contribute permission to site (general) but lock down Site Pages
foreach ($user in $contributorUsers) {
    try {
        Set-PnPWebPermission -User $user -AddRole "Contribute"
        Write-Host "Granted contribute permissions to $user on SharePoint." -ForegroundColor Green
    } catch {
        Write-Warning "Could not grant Contribute permissions to ${user}: $_"
    }
}

# Lock down Site Pages (prevent Contributors from posting news)
Write-Host "`n[+] Locking down Site Pages..." -ForegroundColor Cyan
try {
    $sitePagesList = Get-PnPList -Identity "Site Pages"
    Set-PnPList -Identity $sitePagesList -BreakRoleInheritance -CopyRoleAssignments:$false -ErrorAction Stop
    Write-Host "Broke permission inheritance on Site Pages." -ForegroundColor Yellow

    $sitePages = Get-PnPListItem -List "Site Pages"

    foreach ($user in $contributorUsers) {
        foreach ($item in $sitePages) {
            try {
                Set-PnPListItemPermission -List "Site Pages" -Identity $item.Id -User $user -AddRole "Read"
                Write-Host "Granted read access to $user for Site Page '$($item.FieldValues['FileLeafRef'])'" -ForegroundColor Green
            } catch {
                Write-Warning "Could not set read access to Site Page '$($item.Id)' for ${user}: $_"
            }
        }
    }
} catch {
    Write-Warning "Could not update Site Pages permissions: $_"
}