# connect to exchange
Connect-ExchangeOnline -UserPrincipalName famoll@mollcgc.com

# group email
$group = "mcal@franciscomoll.onmicrosoft.com"

# new owners
$ownerUsers = @(
    "fmoll@mollcgc.com",
    "agnes.moll@mollcgc.com"
)

# new members
$contributorUsers = @(
    "isidro.ramirez@mollcgc.com"
)

# add owner users 
foreach ($user in $ownerUsers) {
    try {
        Add-UnifiedGroupLinks -Identity $group -LinkType Members -Link $user -ErrorAction Stop
        Write-Host "Added $user as a member of the group."
    }
    catch {
        Write-Warning "Could not add $user as a member: $_"
    }

    try {
        Add-UnifiedGroupLinks -Identity $group -LinkType Owners -Links $user -ErrorAction Stop
        Write-Host "Added $user as an owner of the group."
    }
    catch {
        Write-Warning "Failed to add $user as an owner: $_"
    }
}

# add contributors as members, grant calendar access
$calendarIdentity = "${group}:\Calendar"

foreach ($user in $contributorUsers) {
    try {
        Add-UnifiedGroupLinks -Identity $group -LinkType Members -Links $user -ErrorAction Stop
        Write-Host "Added $user as a member of the group."
    }
    catch {
        Write-Warning "Could not add $user as member: $_"
    }

    try {
        Set-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Reviewer
        Write-Host "Added reviewer permission for $user on the group calendar."
    }
    catch {
        try {
            Add-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Reviewer
            Write-Host "Added reviewer permission for $user on the group calendar."
        }
        catch {
            Write-Error "Could not set calendar permission for ${user}: $_"
        }
    }
}

# modify member sharepoint access
# connection details
Connect-PnPOnline -Scopes "Group.Read.All", "Sites.ReadWrite.All" -Interactive