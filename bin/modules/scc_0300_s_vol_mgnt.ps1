$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1

# Reference: https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
$diskPartitions = Get-WmiObject -class Win32_DiskPartition -computername $computer
Write-Output "hlp:Volume Management:partitions::Data from class Win32_DiskPartition"

foreach ($diskPartition in $diskPartitions) {
    Write-Output ("fix:Volume Management:partitions::" + $diskPartition.Name + " " + $diskPartition.Description + " " + ($diskPartition.Size /1024/1024) + "MB")
}

# Reference: https://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
$logicalDisks = Get-WmiObject -class Win32_LogicalDisk -computername $computer
Write-Output "hlp:Volume Management:partitions::Data from class Win32_LogicalDisk"
$driveTypeList = @("Unknown","No Root Directory","Removable Disk","Local Disk","Network Drive","Compact Disc","RAM Disk")

foreach ($logicalDisk in $logicalDisks) {
    # Only drive type 3 ("Local Disk") is fixed, all others are non-local or removable so flag as variable
    if($logicalDisk.DriveType -eq 3) {
        $dataClass = "fix"
    } else {
        $dataClass = "var"
    }
    # Remove colon if it exists in the name (breaks output)
    $diskName = $logicalDisk.Name -replace ":",""
    # Prep label prefixed with disk name
    $label = ($dataClass + ":Volume Management:file systems:" + $diskName + ":")
    # Calculate percentages, only if this disk actually has sizes
    if ($logicalDisk.Size -gt 0 -and $logicalDisk.FreeSpace -gt 0) {
        $freeDiskPercent = $logicalDisk.FreeSpace / $logicalDisk.Size * 100;
        $usedDiskPercent = (($logicalDisk.Size - $logicalDisk.FreeSpace) / $logicalDisk.Size) * 100;
    } else {
        $freeDiskPercent = 0
        $usedDiskPercent = 0
    }
    # Get variables
    Write-Output ($label + "::DriveType:" + $driveTypeList[$logicalDisk.DriveType])
    Write-Output ($label + "::VolumeName:" + $logicalDisk.VolumeName)
    Write-Output ($label + "::VolumeSerialNumber:" + $logicalDisk.VolumeSerialNumber)
    Write-Output ($label + "::Description:" + $logicalDisk.Description)
    Write-Output ($label + "::FileSystem:" + $logicalDisk.FileSystem)
    Write-Output ($label + "::VolumeDirty:" + $logicalDisk.VolumeDirty)
    Write-Output ($label + "::SupportsDiskQuotas:" + $logicalDisk.SupportsDiskQuotas)
    Write-Output ($label + "::Size:" + $logicalDisk.Size)
    Write-Output ($label + "::SizeReadable:" + (sccBytesToString $logicalDisk.Size))
    # These are always variable, regardless of fixed disk or not, so replace fix with var in label
    $label = $label -replace "fix","var"
    Write-Output ($label + "::FreeSpace:" + $logicalDisk.FreeSpace)
    Write-Output ($label + "::FreeSpaceReadable:" + (sccBytesToString $logicalDisk.FreeSpace))
    Write-Output ($label + "::FreeSpacePercentage:" + [math]::Round($freeDiskPercent, 2) + "%")
    Write-Output ($label + "::UsedSpace:" + ($logicalDisk.Size - $logicalDisk.FreeSpace))
    Write-Output ($label + "::UsedSpaceReadable:" + (sccBytesToString ($logicalDisk.Size - $logicalDisk.FreeSpace)))
    Write-Output ($label + "::UsedSpacePercentage:" + [math]::Round($usedDiskPercent, 2) + "%")

}
