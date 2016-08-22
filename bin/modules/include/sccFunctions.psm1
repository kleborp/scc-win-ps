function sccBytesToString ($bytes) {
    if($bytes -lt 1MB) {
        $size  = [math]::round(($bytes / 1KB), 2)
        $size = ("$size" + " KB")
    } elseif ($bytes -lt 1GB) {
        $size  = [math]::round(($bytes / 1MB), 2)
        $size = ("$size" + " MB")
    } elseif ($bytes -lt 1TB) {
        $size  = [math]::round(($bytes / 1GB), 2)
        $size = ("$size" + " GB")
    } else {
        $size  = [math]::round(($bytes / 1TB), 2)
        $size = ("$size" + " TB")
    }
    return $size
}

# Timing function
# Record total time, start at 0
$global:totalTime = 0;
function sccTiming($module, $label, $timeTaken = 0) 
{
    # Increase the total time every time this is called
    $global:totalTime += $timeTaken
    # Get current time
    $timestamp = Get-Date -Format HH.mm.ss
    # Log stats
    Write-Output ("stats:profiling::${timestamp}:" + [math]::Round($timeTaken,3) + ":" + [math]::Round($global:totalTime,3) + ":${module}:${label}")
}