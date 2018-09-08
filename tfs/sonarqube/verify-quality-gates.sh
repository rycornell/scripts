#!/bin/bash

# Get task metadata from file

echo "Parameters"
echo '$0 = ' $0
echo '$1 = ' $1

if [ "$1" = "" ]; then
	# use the default relative path of the task on the linux build agent: /agents/TFS-Build05-agent1/_work/2/.sonarqube/out/.sonar/report-task.txt
    reportFile="../.sonarqube/out/.sonar/report-task.txt"
else
    reportFile="$1"
fi

echo "Report File: $reportFile"

# load the report file, which is name/value pairs, so we can easily grab the task Url
. "$reportFile"
taskUrl=$ceTaskUrl

echo "SonarQube Task Url: $taskUrl"

# Poll SonarQube for quality gate results

x=10
while [ $x -gt 0 ]
do
    sleep 1s
    echo "Waiting on SonarQube results..."
    x=$(( $x - 1 ))
    
    taskResult=$(curl -sS $taskUrl)
    taskStatus=$(jq -r '.task.status' <<< "$taskResult")
    
    echo "SonarQube analysis status: $taskStatus"
    
    if [ "$taskStatus" != "PENDING" ] && [ "$taskStatus" != "IN_PROGRESS" ] && [ "$taskStatus" != "" ]; then
        echo "SonarQube analysis is complete. $taskStatus"
        break
    fi
done

if [ "$taskStatus" != "SUCCESS" ]; then
    echo "SonarQube analysis unsuccessful. Failing the build."
    exit 1
fi

# Get the quality gate result

analysisId=$(jq -r '.task.analysisId' <<< "$taskResult")

gateStatus=$(curl -sS http://example.com:9000/api/qualitygates/project_status?analysisId=$analysisId | jq -r '.projectStatus.status')

if [ "$gateStatus" = "OK" ]; then
    echo "All Quality Gates have passed! $gateStatus"
else
    echo "Quality Gates failed. $gateStatus"
    exit 1
fi