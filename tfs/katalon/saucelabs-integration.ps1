Get-ChildItem "$env:BUILD_SOURCESDIRECTORY\settings" -Filter "com.kms.katalon.core.webui.remote.properties" -Recurse | % {
  $propFile = [IO.File]::ReadAllText($_.FullName) | ConvertFrom-Json  
  $propFile.REMOTE_WEB_DRIVER | Add-Member -Type NoteProperty -Name 'build' -Value $env:SAUCE_BUILD_NAME
  $propFile.REMOTE_WEB_DRIVER | Add-Member -Type NoteProperty -Name 'name' -Value $env:SAUCE_BUILD_NAME
  $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl = $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl.Replace('${SAUCE_USERNAME}', $env:SAUCE_USERNAME)
  $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl = $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl.Replace('${SAUCE_ACCESS_KEY}', $env:SAUCE_ACCESS_KEY)
  $propFile | ConvertTo-Json  | set-content $_.FullName
}
