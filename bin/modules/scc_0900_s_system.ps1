$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1
<#
## Windows Update Settings
# Reference: https://technet.microsoft.com/en-gb/library/dd939844(v=ws.10).aspx
$registryObject =[microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$computer)
# WSUS Config lives here
$winUpdateKey = "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$registryKey = $registryObject.OpenSubKey($winUpdateKey)
if($registryKey) {
    Write-Output ("fix:system:Auto Update::WUServer:" + $registryKey.GetValue("WUServer"))
    Write-Output ("fix:system:Auto Update::WUStatusServer:" + $registryKey.GetValue("WUStatusServer"))
}

# Update settings live here
$winUpdateSettingsKey = "$winUpdateKey\AU"
$registryKey = $registryObject.OpenSubKey($winUpdateSettingsKey)

$auOptionList = @("","","Notify before download","Automatically download and notify of installation","Automatically download and schedule installation","Automatic Updates is required and users can configure it")
$auInstallDayList = @("Every day","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
if($registryKey) {
    Write-Output ("fix:system:Auto Update::AUOptions:" + $auOptionList[$registryKey.GetValue("AUOptions")])
    Write-Output ("fix:system:Auto Update::AutoInstallMinorUpdates:" + $registryKey.GetValue("AutoInstallMinorUpdates"))
    Write-Output ("fix:system:Auto Update::DetectionFrequency:" + $registryKey.GetValue("DetectionFrequency"))
    Write-Output ("fix:system:Auto Update::DetectionFrequencyEnabled:" + $registryKey.GetValue("DetectionFrequencyEnabled"))
    Write-Output ("fix:system:Auto Update::NoAutoUpdate:" + $registryKey.GetValue("NoAutoUpdate"))
    Write-Output ("fix:system:Auto Update::NoAutoRebootWithLoggedOnUsers:" + $registryKey.GetValue("NoAutoRebootWithLoggedOnUsers"))
    Write-Output ("fix:system:Auto Update::AutoInstallMinorUpdates:" + $registryKey.GetValue("AutoInstallMinorUpdates"))
    Write-Output ("fix:system:Auto Update::RebootRelaunchTimeoutEnabled:" + $registryKey.GetValue("RebootRelaunchTimeoutEnabled"))
    Write-Output ("fix:system:Auto Update::UseWUServer:" + $registryKey.GetValue("UseWUServer"))
    Write-Output ("fix:system:Auto Update::ScheduledInstallDay:" + $auInstallDayList[$registryKey.GetValue("ScheduledInstallDay")])
    Write-Output ("fix:system:Auto Update::ScheduledInstallTime:" + $registryKey.GetValue("ScheduledInstallTime"))
}

## System Drivers
# Reference: https://msdn.microsoft.com/en-us/library/aa394472(v=vs.85).aspx
$systemDrivers = Get-WmiObject -class Win32_SystemDriver -computername $computer
Write-Output "hlp:system:SystemDriver::Data from class Win32_SystemDriver"


foreach($systemDriver in $systemDrivers | Sort-Object -Property Name) {
    $label = ("system:SystemDriver:" + $systemDriver.Name)
    Write-Output ("fix:" + $label + "::Description:" + $systemDriver.Description)
    Write-Output ("fix:" + $label + "::AcceptPause:" + $systemDriver.AcceptPause)
    Write-Output ("var:" + $label + "::AcceptStop:" + $systemDriver.AcceptStop)
    Write-Output ("fix:" + $label + "::DesktopInteract:" + $systemDriver.DesktopInteract)
    Write-Output ("fix:" + $label + "::ErrorControl:" + $systemDriver.ErrorControl)
    Write-Output ("fix:" + $label + "::PathName:" + $systemDriver.PathName)
    Write-Output ("fix:" + $label + "::ServiceType:" + $systemDriver.ServiceType)
    Write-Output ("fix:" + $label + "::StartMode:" + $systemDriver.StartMode)
    Write-Output ("var:" + $label + "::State:" + $systemDriver.State)
}


## Installed Updates
# Reference: https://msdn.microsoft.com/en-us/library/aa394391(v=vs.85).aspx
$hotfixes = Get-WmiObject -class Win32_QuickFixEngineering -computername $computer
Write-Output "hlp:system:hotfix::Data from class Win32_QuickFixEngineering"


foreach($hotfix in $hotfixes | Sort-Object -Property HotFixID) {
    $label = ("fix:system:hotfix:" + $hotfix.HotFixID)
    # Apparently the description can be more than 1 line
    foreach($desc in $hotfix.Description.Split("`n")) {
        Write-Output ($label + "::Description:" + $desc)
    }
    Write-Output ($label + "::FixComments:" + $hotfix.FixComments)
    Write-Output ($label + "::InstalledBy:" + $hotfix.InstalledBy)
    Write-Output ($label + "::InstalledOn:" + $hotfix.InstalledOn)
    Write-Output ($label + "::ServicePackInEffect:" + $hotfix.ServicePackInEffect)
}

## Services
# Reference: https://msdn.microsoft.com/en-us/library/aa394418(v=vs.85).aspx
$services = Get-WmiObject -class Win32_Service -computername $computer
Write-Output "hlp:system:services::Data from class Win32_Service"

foreach($service in $services | Sort-Object -Property Name) {
    $label = ("system:services:" + $service.Name)
    Write-Output ("fix:" + $label + "::DisplayName:" + $service.DisplayName)
    Write-Output ("fix:" + $label + "::Description:" + $service.Description)
    Write-Output ("fix:" + $label + "::PathName:" + $service.PathName)
    Write-Output ("fix:" + $label + "::ServiceType:" + $service.ServiceType)
    Write-Output ("fix:" + $label + "::StartName:" + $service.StartName)
    Write-Output ("fix:" + $label + "::StartMode:" + $service.StartMode)
    Write-Output ("var:" + $label + "::Started:" + $service.Started)
    Write-Output ("var:" + $label + "::State:" + $service.State)
    Write-Output ("var:" + $label + "::AcceptStop:" + $service.AcceptStop)
    Write-Output ("var:" + $label + "::AcceptPause:" + $service.AcceptPause)
    Write-Output ("fix:" + $label + "::ErrorControl:" + $service.ErrorControl)
}

## Service Dependencies
# Reference: https://msdn.microsoft.com/en-us/library/aa394120(v=vs.85).aspx
$serviceDependencies = Get-WmiObject -class Win32_DependentService -computername $computer
Write-Output "hlp:system:services::Data from class Win32_DependentService"

foreach($serviceDependency in $serviceDependencies | Sort-Object -Property Antecedent) {
    # antecendent and dependent are in the form of "\\<hostname>\root\cimv2:Win32_Service.Name="<servicename>"
    # Extract using regex, we don't care about system driver dependencies
    if($serviceDependency.Antecedent -notmatch 'Win32_SystemDriver') {
        $regex = '.*Name=\"(.*)\"'
        $antecendent = [regex]::match($serviceDependency.Antecedent, $regex).Groups[1].Value
        $dependent = [regex]::match($serviceDependency.Dependent, $regex).Groups[1].Value
        Write-Output ("fix:system:services:" + $antecendent + "::Required by:" + $dependent)
    }
} #>

## Firewall Configuration
$firewallBaseKey = "SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\"
# There are 3 profiles, Standard, Domain and Public, get config for each
foreach ($profile in "StandardProfile","DomainProfile","PublicProfile") {
    $registryPath = ($firewallBaseKey + $profile)
    $registryObject = [microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$computer)
    $registryKey = $registryObject.OpenSubKey($registryPath)

    $label = ("fix:system:firewall:" + $profile)
    Write-Host ($label + "::EnableFirewall:" + $registryKey.GetValue("EnableFirewall"))
    Write-Host ($label + "::DisableNotifications:" + $registryKey.GetValue("DisableNotifications"))
}

## Firewall Rules
# TODO: Implement parsing of Get-NetFirewallRule

## Scheduled Tasks
# On Windows 10 and Server 2012 you can use Get-ScheduledTask
# For now use schtasks command which is Win 7 and Server 2008 compatible
#$scheduledTasksCmd = ("schtasks /query /v /fo csv /s " + $computer)
#$tasks = Invoke-Expression($scheduledTasksCmd)
$tasks = Get-ScheduledTask

foreach($task in $tasks) {
    $label = (":system:scheduled tasks:" + $task.TaskName)
    Write-Output ("fix" + $label + "::Author:" + $task.Author)
    Write-Output ("fix" + $label + "::TaskPath:" + $task.TaskPath)
    Write-Output ("var" + $label + "::State:" + $task.State)
    foreach($action in $task.Actions) {
        Write-Output ("fix" + $label + "::Action:" + $action.Execute)
    }
    foreach($trigger in $task.Triggers) {
        Write-Output ("fix" + $label + "::Trigger:" + $trigger.Id)
        #$trigger.Id
    }
}