$filename = "$env:BUILD_SOURCESDIRECTORY\settings\internal\com.kms.katalon.core.webui.remote.properties"

$propFile = [IO.File]::ReadAllText($filename) | ConvertFrom-Json

$propFile.REMOTE_WEB_DRIVER | Add-Member -Type NoteProperty -Name "build" -Value $env:SAUCE_BUILD_NAME

$propFile.REMOTE_WEB_DRIVER | Add-Member -Type NoteProperty -Name "name" -Value $env:SAUCE_BUILD_NAME

$propFile | ConvertTo-Json  | Set-Content $filename