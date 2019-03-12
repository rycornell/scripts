# The download url was in the format https://download.katalon.com/x.x.x/Katalon_Studio_Windows_64-x.x.x.zip
#
# Example: https://download.katalon.com/5.10.1/Katalon_Studio_Windows_64-5.10.1.zip
#
# However, it recently changed to this format:
#
# Example: https://download.katalon.com/6.0.4/Katalon_Studio_Windows_64.zip

# Params:
#  Katalon Version Number - $OctopusParameters["KatalonVersion"]

Write-Host Running script on $env:COMPUTERNAME

$version = $OctopusParameters["KatalonVersion"]
$platform = "Windows_64"
$zipFileName = "Katalon_Studio_$platform.zip"
$url = "https://download.katalon.com/$version/$zipFileName"
$downloadPath = "C:\Program Files\Katalon\$zipFileName"
$extractPath = "C:\Program Files\Katalon\Katalon_Studio_$platform-$version\"    

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -assembly "System.IO.Compression.Filesystem";

if (Test-Path $extractPath)
{
	Write-Host Folder $extractPath already exists. Exiting.
	return
}

Write-Host Downloading $url to $downloadPath ...

(New-Object System.Net.WebClient).DownloadFile($url, $downloadPath)

Write-Host Unzipping $downloadPath to $extractPath ...

[System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $extractPath)

Write-Host Deleting $downloadPath ...

$attempts = 0
$deleted = $false
while ($attempts -lt 20 -and $deleted -eq $false)
{
	try {
		Remove-Item -Path $downloadPath -Force -ErrorAction Stop
		$deleted = $true
	} catch {
		Write-Host ...
		sleep -Seconds 10
	}
	$attempts++         
}

if ($deleted -eq $false){
	Write-Host Unable to delete $downloadPath
}

Write-Host Done!