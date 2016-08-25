$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1

# Obtains Windows key
# TODO: Make it use remote registry instead so it can be run remotely
function Get-ProductKey {
    $map="BCDFGHJKMPQRTVWXY2346789" 
    $value = (get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42]  
    $ProductKey = ""  
    for ($i = 24; $i -ge 0; $i--) { 
      $r = 0 
      for ($j = 14; $j -ge 0; $j--) { 
        $r = ($r * 256) -bxor $value[$j] 
        $value[$j] = [math]::Floor([double]($r/24)) 
        $r = $r % 24 
      } 
      $ProductKey = $map[$r] + $ProductKey 
      if (($i % 5) -eq 0 -and $i -ne 0) { 
        $ProductKey = "-" + $ProductKey 
      } 
    } 
    $ProductKey
}

# TODO
function Get-OfficeKey {
    
}

# We'll store installed software in this:
$installedSoftware = @{}

# Loop over both 32bit and 64bit registry keys
foreach ($regPath in @('', 'Wow6432Node\')) {
    
    # Build key depending on bitness
    $uninstallKey = (”SOFTWARE\" + $regPath + "Microsoft\Windows\CurrentVersion\Uninstall”)
    Write-Output ("hlp:network:general::Data from registry: HKLM:\" + $uninstallKey)

    # Open registry key
    $registryObject =[microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$computer)
    $registryKey = $registryObject.OpenSubKey($uninstallKey)
    # Get all subkeys under the uninstall key
    $registrySubKeys = $registryKey.GetSubKeyNames()


    # Loop over each subkey under Uninstall and add to installedSoftware
    $i = $installedSoftware.Count
    foreach($key in $registrySubKeys) {
        $thiskey = $uninstallKey + "\\" + $key
        $thisSubKey = $registryObject.OpenSubKey($thiskey)

        $displayName = $thisSubKey.GetValue("DisplayName")
        if($displayName) {
            $installedSoftware[$i] = @{}
            $installedSoftware[$i]["DisplayName"] = $displayName
            # Remove funky characters from publisher name (Microsoft likes putting null characters in here)
            $publisher = $thisSubKey.GetValue("Publisher") -Replace '[\W]', ''
            $installedSoftware[$i]["Publisher"] = $publisher
            $installedSoftware[$i]["DisplayVersion"] = $thisSubKey.GetValue("DisplayVersion")
            $installedSoftware[$i]["InstallDate"] = $thisSubKey.GetValue("InstallDate")
            $installedSoftware[$i]["InstallLocation"] = $thisSubKey.GetValue("InstallLocation")
            $installedSoftware[$i]["NoModify"] = $thisSubKey.GetValue("NoModify")
            $installedSoftware[$i]["NoRemove"] = $thisSubKey.GetValue("NoRemove")
            $installedSoftware[$i]["NoRepair"] = $thisSubKey.GetValue("NoRepair")
            $installedSoftware[$i]["URLInfoAbout"] = $thisSubKey.GetValue("URLInfoAbout")
            $installedSoftware[$i]["WindowsInstaller"] = $thisSubKey.GetValue("WindowsInstaller")
            $i++
        }
    }
}

# Output data for each product we found
# TODO: Sort this by DisplayName somehow
foreach ($key in $installedSoftware.Keys) {
    # Remove : from DisplayName
    $displayName = $installedSoftware[$key]["DisplayName"] -replace ":","_"
    $label = ("fix:software:product:" + $displayName)
    Write-Output ($label + "::Publisher:" + $installedSoftware[$key]["Publisher"])
    Write-Output ($label + "::DisplayVersion:" + $installedSoftware[$key]["DisplayVersion"])
    Write-Output ($label + "::InstallDate:" + $installedSoftware[$key]["InstallDate"])
    Write-Output ($label + "::InstallLocation:" + $installedSoftware[$key]["InstallLocation"])
    Write-Output ($label + "::NoModify:" + $installedSoftware[$key]["NoModify"])
    Write-Output ($label + "::NoRemove:" + $installedSoftware[$key]["NoRemove"])
    Write-Output ($label + "::NoRepair:" + $installedSoftware[$key]["NoRepair"])
    Write-Output ($label + "::URLInfoAbout:" + $installedSoftware[$key]["URLInfoAbout"])
    Write-Output ($label + "::WindowsInstaller:" + $installedSoftware[$key]["WindowsInstaller"])
    
}
# Clear this in case we re-run the script in the same scope
Remove-Variable installedSoftware
$OSkey = Get-ProductKey
Write-Output ("fix:software:product keys:OS:" + $OSkey)

