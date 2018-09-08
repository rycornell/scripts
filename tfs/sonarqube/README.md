# SonarQube Quality Gate Verification for TFS Builds
These scripts will fail a TFS build if it does not pass the SonarQube quality gates.

The powershell script `verify-quality-gates.ps1` should be used for Windows build agents.  The bash script `verify-quality-gates.sh` should be used for Linux build agents.

These were inspired by https://github.com/aboullaite/useful-scripts/blob/master/quality-gates-jenkins.groovy

If you use VSTS/TFS, I recommend the [SonarQube build breaker](https://marketplace.visualstudio.com/items?itemName=SimondeLang.sonar-buildbreaker#qna) extension.