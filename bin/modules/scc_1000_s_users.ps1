$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1

## Get Users
# Reference: https://msdn.microsoft.com/en-us/library/aa394507(v=vs.85).aspx
$users = Get-WmiObject -class Win32_UserAccount -computername $computer
Write-Output "hlp:users:local users::Data from class Win32_UserAccount"

# List of SID types
$sidTypeList = @("","User","Group","Domain","Alias","WellKnownGroup","DeletedAccount","Invalid","Unknown","Computer")
foreach($user in $users) {
    $label = ("fix:users:local users:" + $user.Name)
     Write-Output ($label + "::Description:" + $user.Description)
     Write-Output ($label + "::FullName:" + $user.FullName)
     Write-Output ($label + "::SID:" + $user.SID)
     Write-Output ($label + "::SIDType:" + $sidTypeList[$user.SIDType])
     Write-Output ($label + "::AccountType:" + $user.AccountType)
     Write-Output ($label + "::LocalAccount:" + $user.LocalAccount)
     Write-Output ($label + "::Disabled:" + $user.Disabled)
     Write-Output ($label + "::Domain:" + $user.Domain)
     Write-Output ($label + "::Lockout:" + $user.Lockout)
     Write-Output ($label + "::PasswordChangeable:" + $user.PasswordChangeable)
     Write-Output ($label + "::PasswordRequired:" + $user.PasswordRequired)
     Write-Output ($label + "::PasswordExpires:" + $user.PasswordExpires)
     Write-Output ($label + "::Status:" + $user.Status)
}

## Get Groups
# Reference: https://msdn.microsoft.com/en-us/library/aa394151(v=vs.85).aspx
$groups = Get-WmiObject -class Win32_Group -computername $computer
Write-Output "hlp:users:local groups::Data from class Win32_Group"
foreach($group in $groups) {
    $label = ("fix:users:local groups:" + $group.Name)
    Write-Output ($label + "::Description:" + $group.Description)
    Write-Output ($label + "::SID:" + $group.SID)
    Write-Output ($label + "::SIDType:" + $sidTypeList[$group.SIDType])
    Write-Output ($label + "::Domain:" + $group.Domain)
    Write-Output ($label + "::Status:" + $group.Status)
}

## Get Group / User relation (reuse $groups variable)
# Reference: https://msdn.microsoft.com/en-us/library/aa394153(v=vs.85).aspx
foreach ($group in $groups) {
    $groupUsers = Get-WmiObject -class Win32_GroupUser -computername $computer -Filter ("GroupComponent=`"Win32_Group.Domain='" + $group.Domain + "',Name='" + $group.Name + "'`"")
    foreach($groupUser in $groupUsers) {
        write-output $groupuser.GroupComponent
        Write-Output $groupuser.PartComponent
    }
}