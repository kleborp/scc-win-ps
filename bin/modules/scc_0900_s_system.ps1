$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1

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


foreach($hotfix in $hotfixes | Sort-Object -Property Name) {
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