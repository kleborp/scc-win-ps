$ftpServer = "localhost"
$ftpUsername = "inbound"
$ftpPassword = "inbound"
$ftpFile = "test"
$ftpURI = ("ftp://" + $ftpServer + "/" + $ftpFile)

# Create FTP connection
$ftpObject = [System.Net.FtpWebRequest]::Create($ftpURI)
$ftpObject.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)
$ftpObject.EnableSsl = $true
$ftpObject.UseBinary = $true
$ftpObject.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$ftpRequestStream = $ftpObject.GetRequestStream()

