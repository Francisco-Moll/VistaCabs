# calendar identity
$calendarIdentity = "vistacabinetscalendar@franciscomoll.onmicrosoft.com:\Calendar"

# list of users
$users = @(
    "famoll@mollcgc.com",
    "fmoll@mollcgc.com",
    "agnes.moll@mollcgc.com"
)

foreach ($user in $users) {
    try {
        Set-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Owner -ErrorAction Stop
        Write-Host "Set Owner permissions for $user"
    }
    catch {
        Write-Warning "Failed to set permissions for $user. Trying to add new permission..."
        try {
            Add-MailboxFolderPermission -Identity $calendarIdentity -User $user -AccessRights Owner
            Write-Host "Added Owner permissions for $user"
        }
        catch {
            Write-Error "Could not add or update permissions for $user. Error: $_"
        }
    }
}