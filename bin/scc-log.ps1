# This script invokes the collector and validates the output
# It also adds some generic statistics about start/end/date/runtime

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
$sccModulePath = "$sccBinPath\modules\"

$sccSnapshotCurrent = "$sccDataPath" + "scc." + $hostname + ".cur"
$sccSnapshotOld = "$sccDataPath" + "scc." + $hostname + ".old"
$sccSnapshotTmp = "$sccDataPath" + "scc." + $hostname + ".tmp"

# Run the collector
$dataCollection = Invoke-Expression $sccBinPath\scc-collect.ps1

# Write output to file (and show to console)
$dataCollection | Out-File -FilePath $sccSnapshotCurrent
#$dataCollection | Tee-Object -FilePath $sccSnapshotCurrent
$dataSize = (Get-Item $sccSnapshotCurrent).Length

$endTime = Get-Date
$runTime = New-TimeSpan -Start $startTime -End $endTime

# Prep some timestamps for logging
$dateString = $startTime | Get-Date -Format "dd-MM-yyyy"
$startString = $startTime | Get-Date -Format "HH.mm.ss"
$endString = $endTime | Get-Date -Format "HH.mm.ss"

Write-Host ("var:general::date:" + $dateString)
Write-Host ("var:general::start time:" + $startString)
Write-Host ("var:general::stop time:" + $endString)
Write-Host ("var:general::runtime:" + $runTime.Seconds)
Write-Host ("var:general::size (MB):" + [math]::Round($dataSize / (1024*1024),3))

# Validate the data we collected
foreach ($line in $dataCollection) {
    if($line -match '^fix:messages:') {
        #Write-Host $line
    }
    if($line -match '^fix:' -or $line -match '^var:' -or $line -match '^hlp:') {

    } elseif ($line -match '^stats:') {
        Write-Host $line
    } else {
        Write-Host ("fix:messages:unknown prefix:" + $line)
    }
}

