# This will be the main script started on a schedule
# It will eventually:
# - Resolve the FQDN for remote collection if needed
# - Process/validate command line options
# - Ensure script is run as Administrator
# - For each host:
# -- Run scc-log.ps1 (args: comment extra timeout hostname)
# -- Pack up all files generated (scc.$hostname.cur, .log, .log.html and .html)
# -- Transfer packaged up file using mail, copy or ftp(s)

# The original perl script takes these arguments:
# [ --file <file> ] [ --list <list> ] [ --netview ]
# [ --missing ] [ --min_age <hours> ]
# [ --delay <delay> ] [ --extra <mod> ] [ --norun ] [ --encrypt <file> ]
# [ --from <mail> ] [ --dest <dest> ] [ --passwd <pw> ] [ --pki <file> ]
# [ --prog <prog> ] [ --smtp <smtp> ] [ --trace ] [ --report <file> ]
# [ --timeout <duration> ] [ --comment <remark> ] [ --help ] [ --version ]
# [ --new_pack ]

# Hostname of local machine
$hostname = "$env:COMPUTERNAME".ToLower()

# Test file to upload
$sccPath = $currentPath | Split-Path -Parent
$sccDataPath = "$sccPath\data\"
$sccSnapshotCurrent = "$sccDataPath" + "scc." + $hostname + ".cur"

# For testing FTP 
$paramProg = "ftp"
$paramDest = "inbound@localhost"
$paramPasswd = "inbound"
$ftpUsername = ($paramDest -split("@"))[0]
$ftpHostname = ($paramDest -split("@"))[1]
$ftpFile = ("scc." + $hostname + ".cur")
$ftpURI = ("ftp://" + $ftpHostname + "/" + $ftpFile)

# Connect to FTP
$ftpObject = [System.Net.FtpWebRequest]::Create($ftpURI)
$ftpObject.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $paramPasswd)
$ftpObject.EnableSsl = $true
$ftpObject.UseBinary = $true
$ftpObject.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
# This may fail, this is when connection is opened and file upload started
try {
    $ftpRequestStream = $ftpObject.GetRequestStream()
} catch {
    Write-Host "Error opening FTP Stream"
    exit 
}

# Open file for reading
$fileStream = New-Object System.IO.FileStream ($sccSnapshotCurrent, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
# Create file buffer (4kb at a time)
[byte[]]$readBuffer = New-Object byte[] 4096

# Read source file, write to ftp
do {
    $readLength = $fileStream.Read($readBuffer, 0, $readBuffer.length)
    $ftpRequestStream.Write($readBuffer,0,$readLength)
} while($readLength -gt 0)
# Close file
$fileStream.Close()
# Close FTP connection
$ftpRequestStream.Close()

$ftpResponse = $ftpObject.GetResponse()
Write-Host $ftpResponse.StatusDescription