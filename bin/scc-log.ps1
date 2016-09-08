# This script invokes the collector and validates the output
# It also adds some generic statistics about start/end/date/runtime

# Todo: 
# - Implement calling arguments (comment extra timeout hostname)
# - Implement passing of hostname to modules

$hostname = "$env:COMPUTERNAME".ToLower()
$startTime = Get-Date


# Figure out some paths
# Currently running from bin
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
# SCC root is the parent of current path
$sccPath = $currentPath | Split-Path -Parent
# We're currently running from bin
$sccBinPath = "$currentPath\"
# Data and tmp paths
$sccDataPath = "$sccPath\data\"
$sccTmpPath = "$sccPath\tmp\"
# This will create paths if it does not exist
New-Item -ItemType Directory -Force -Path $sccDataPath | Out-Null
New-Item -ItemType Directory -Force -Path $sccTmpPath | Out-Null

$sccModulePath = "$sccBinPath\modules\"

$sccSnapshotCurrent = "$sccDataPath" + "scc." + $hostname + ".cur"
$sccSnapshotOld = "$sccDataPath" + "scc." + $hostname + ".old"
$sccSnapshotTmp = "$sccDataPath" + "scc." + $hostname + ".tmp"

# Rename the last snapshot to .old if it exists
if(Test-Path($sccSnapshotCurrent)) {
    Move-Item -Force $sccSnapshotCurrent $sccSnapshotOld
}

# Run the collector
$dataCollection = Invoke-Expression $sccBinPath\scc-collect.ps1

# Function to process the data
function Generate-SCCSnapshot ($start, $data) {
    # Calculate size and time taken
    # This is not accurate, need to find better way of measuring what size the file will be
    $dataSize = ("" + $data + "").Length
    $endTime = Get-Date
    $runTime = New-TimeSpan -Start $start -End $endTime

    # Prep some timestamps for logging
    $dateString = $startTime | Get-Date -Format "dd-MM-yyyy"
    $startString = $startTime | Get-Date -Format "HH.mm.ss"
    $endString = $endTime | Get-Date -Format "HH.mm.ss"

    Write-Output ("var:general::date:" + $dateString)
    Write-Output ("var:general::start time:" + $startString)
    Write-Output ("var:general::stop time:" + $endString)
    Write-Output ("var:general::runtime:" + $runTime.Seconds)
    Write-Output ("var:general::size (MB):" + [math]::Round($dataSize / (1024*1024),3))

    # Validate the data we collected
    foreach ($line in $data) {
        if($line -match '^fix:messages:') {
            # Just write out any messages reported by modules
            Write-Output $line
        }
        if($line -match '^fix:' -or $line -match '^var:' -or $line -match '^hlp:') {
            # TODO: Check consistency of data, for now just write out
            Write-Output $line
        } elseif ($line -match '^stats:') {
            # We trust the stats are right
            Write-Output $line
        } else {
            # Anything that didn't match the above is prefixed with something we don't recognise, add "fix:messages:unknown prefix" label
            Write-Output ("fix:messages:unknown prefix:" + $line)
        }
    }
}

# This one writes to file and to console
#Generate-SCCSnapshot $startTime $dataCollection | Tee-Object -FilePath $sccSnapshotCurrent
# This one only writes to file
Generate-SCCSnapshot $startTime $dataCollection | Out-File -FilePath $sccSnapshotCurrent

