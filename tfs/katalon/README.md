# Run Katalon Tests in Sauce Labs from TFS Build
Katalon Studio has the ability to execute tests in Sauce Labs, but there are some modifications that need to be made to fully integrate the test results between Sauce Labs and TFS.

In order to achieve a full integration, the Sauce Labs "build" capability needs to be set to the environment variable "SAUCE_BUILD_NAME".

It's typically done like this for a C# Selenium test project:
`capabilities.SetCapability("build", Environment.GetEnvironmentVariable("SAUCE_BUILD_NAME"));`

In Katalon, the "build" capability can be set by updating the project's "\settings\internal\com.kms.katalon.core.webui.remote.properties" file.  This file is a json file that contains the Sauce Labs connection info.  This file corresponds to the settings in Katalon Studio 

The powershell script `saucelabs-integration.ps1` updates that file opening it, converting it to a Json object, set both the "build" and "name" capabilities, then saving the file.

This must be done prior to executing the tests.

Here are the TFS build steps needed to integration Katalon tests with Sauce Labs and TFS:

(screenshots/tfs-build-steps.png)