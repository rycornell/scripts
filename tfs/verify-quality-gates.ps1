# README
#
# This can be tested locally by running this command from a powershell prompt:
# & ./verify-quality-gates.ps1 "C:\report-task.txt"
#
# This is a sample report-task.txt file:
# https://github.com/SonarQubeCommunity/sonar-build-breaker/blob/master/src/test/resources/org/sonar/plugins/buildbreaker/report-task.txt
#
# END README

# Get task metadata from file

Write-Host "Parameters"
foreach ($arg in $args) {
    Write-Host "Arg: $arg"
}

if ($args.Length -eq 0) {
    # use the default relative path of the task on the build agent: /agents/TFS-Build05-agent1/_work/2/.sonarqube/out/.sonar/report-task.txt
    $reportFile = "../.sonarqube/out/.sonar/report-task.txt"
} else {
    $reportFile = $args[0]
}

Write-Host "Report File: $reportFile"

# load the report file, which is name/value pairs, so we can easily grab the task Url
$reportFileProps = ConvertFrom-StringData (Get-Content $reportFile -Raw)
$taskUrl = $reportFileProps.'ceTaskUrl'

Write-Host "SonarQube Task Url: $taskUrl"

# Poll SonarQube for quality gate results

$x = 10
while ($x -gt 0) {
    Start-Sleep -Seconds 1
    Write-Host "Waiting on SonarQube results..."
    $x -= 1

    try {
        $taskResult = Invoke-RestMethod $taskUrl
    }
    catch {
        Write-Host "An error occurred getting the SonarQube results: $_"
    }

    $taskStatus = $taskResult.task.status

    Write-Host "SonarQube analysis status: $taskStatus"

    if (($taskStatus -ne "PENDING") -and ($taskStatus -ne "IN_PROGRESS") -and ($taskStatus -ne "")) {
        Write-Host "SonarQube analysis is complete. $taskStatus"
        break
    }
}

if ("$taskStatus" -ne "SUCCESS") {
    Write-Host "SonarQube analysis unsuccessful. Failing the build."
    exit 1
}

# Get the quality gate result

$analysisId = $taskResult.task.analysisId
Write-Host "Analysis Id: $analysisId"

try {
    $gateResult = Invoke-RestMethod "http://example.com:9000/api/qualitygates/project_status?analysisId=$analysisId"
}
catch {
    Write-Host "An error occurred getting the gate results: $_"
}

$gateStatus = $gateResult.projectStatus.status

if ($gateStatus -eq "OK") {
    Write-Host "All Quality Gates have passed! $gateStatus"
}
else {
    Write-Host "Quality Gates failed. $gateStatus"
    exit 1
}