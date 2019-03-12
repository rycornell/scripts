[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    Import-VstsLocStrings "$PSScriptRoot\Task.json"

    # Get task variables.
    [bool]$debug = Get-VstsTaskVariable -Name System.Debug -AsBool

    # Get the inputs.
    [string]$projectFolderPath = Get-VstsInput -Name ProjectFolderPath -Require
    [string]$isTestSuiteCollection = Get-VstsInput -Name IsTestSuiteCollection -Require -AsBool
    [string]$testSuiteName = Get-VstsInput -Name TestSuiteName -Require
    [string]$executionProfile = Get-VstsInput -Name ExecutionProfile
    [string]$browserType = Get-VstsInput -Name BrowserType
    [string]$useProxy = Get-VstsInput -Name UseProxy -Require -AsBool
    [string]$proxyOption = Get-VstsInput -Name ProxyOption
    [string]$proxyServerType = Get-VstsInput -Name ProxyServerType
    [string]$proxyServerAddress = Get-VstsInput -Name ProxyServerAddress
    [string]$proxyServerPort = Get-VstsInput -Name ProxyServerPort
    [string]$retries = Get-VstsInput -Name Retries
    [string]$retryFailedTestCasesOnly = Get-VstsInput -Name RetryFailedTestCasesOnly -AsBool
    [string]$emailRecipient = Get-VstsInput -Name EmailRecipient
    [string]$katalonVersion = Get-VstsInput -Name KatalonVersion

    # Get the project file path
    $sourceDirectory = $env:BUILD_SOURCESDIRECTORY
    $projectFilePath = Get-ChildItem "$sourceDirectory\$projectFolderPath" -Filter "*.prj" | Select-Object -Expand FullName

    # Configure the desired capabilities for Sauce Labs    
    $settingFiles = Get-ChildItem "$sourceDirectory\$projectFolderPath\settings" -Filter "com.kms.katalon.core.webui.remote.properties" -Recurse
    foreach ($file in $settingFiles) {
        $propFile = [IO.File]::ReadAllText($file.FullName) | ConvertFrom-Json

        # Set the 'build' and 'name' desired capabilities to the name of the TFS Build
        if ($null -eq ($propFile.REMOTE_WEB_DRIVER | Get-Member -MemberType NoteProperty -Name 'build'))
        {
            $propFile.REMOTE_WEB_DRIVER | Add-Member -Type NoteProperty -Name 'build' -Value $env:SAUCE_BUILD_NAME
        }
        if ($null -eq ($propFile.REMOTE_WEB_DRIVER | Get-Member -MemberType NoteProperty -Name 'name'))
        {
            $propFile.REMOTE_WEB_DRIVER | Add-Member -Type NoteProperty -Name 'name' -Value $env:SAUCE_BUILD_NAME
        }

        # Set the SauceLabs credentials
        $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl = $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl.Replace('${SAUCE_USERNAME}', $env:SAUCE_USERNAME)
        $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl = $propFile.REMOTE_WEB_DRIVER.remoteWebDriverUrl.Replace('${SAUCE_ACCESS_KEY}', $env:SAUCE_ACCESS_KEY)

        $propFile | ConvertTo-Json | set-content $file.FullName
        $propFile | Write-Host
    }

    # Set the Katalon command line arguments
    $args = @()
    if ($isTestSuiteCollection -eq "true") {
        $args += "-testSuiteCollectionPath=""Test Suites/$testSuiteName"""
    } else {
        $args += "-testSuitePath=""Test Suites/$testSuiteName"""
        $args += "-executionProfile=""$executionProfile"""
        $args += "-browserType=""$browserType"""
    }

    $args += "-retry=$retries"
    
    if ($retryFailedTestCasesOnly -eq "true") {
        $args += "-retryFailedTestCases=true"
    }

    if ($emailRecipient) {
        $args += "-sendMail=""$emailRecipient"""
    }

    if ($useProxy -eq "true") {
        $args += "--config -proxy.option=""$proxyOption"""
        $args += "--config -proxy.server.type=""$proxyServerType"""
        $args += "--config -proxy.server.address=""$proxyServerAddress"""
        $args += "--config -proxy.server.port=""$proxyServerPort"""
    }

    Write-Host "Running Katalon"
    Write-Host "Project: $projectFilePath"
    Write-Host "Arguments: $args"

    cmd /C "`"C:\Program Files\Katalon\Katalon_Studio_Windows_64-$katalonVersion\katalon.exe`" -noSplash -runMode=console -projectPath=`"$projectFilePath`" $args"
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}