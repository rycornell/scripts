# Run Katalon Tests in Sauce Labs from TFS (Azure DevOps) Build
Katalon Studio has the ability to execute tests in Sauce Labs, but there are some modifications that are needed to achieve a full integration.  Here are the steps.

* In Katalon Studio, configure the desired capabilities for Sauce Labs execution.
  * Go to the Project menu > Settings > Desired Capabilities > Custom
  
  _(this menu structure may be different depending on your version of Katalon)_
  * Add entries for each browser configuration you want to test on Sauce Labs:
  
    * In the Name column, set the name to something like "Sauce Labs - Chrome"
    * In the Value column, click the button to open the configuration builder window
    * In the Driver Name column, select Remote
    * In the Preferences column, click the button to open the preferences window
    * Set Remote web server url to 
  
    https://${SAUCE_USERNAME}:${SAUCE_ACCESS_KEY}@ondemand.saucelabs.com:443/wd/hub
    
    _(Note that we are not hard coding the username and access key into the url. We are using tokens that will be substituted when we run the tests on our CI server. If you're not using a CI server or source control, then you should enter your actual username and access key here.)_
  * Add the appropriate Sauce Labs capabilities, which can be found using the [Sauce Labs Platform Configurator](https://wiki.saucelabs.com/display/DOCS/Platform+Configurator#/).  For example,
  
    browserName Chrome
    
    version latest
    
    platform Windows 10
    
    screenResolution 1920x1080
    
  * In the end it should look like this:
  
  ![Desired Capabilities](screenshots/katalon-desired-capabilities.PNG)
    
* Save the project and push to source control
* In TFS, create a build that looks like this:

    ![build steps](screenshots/tfs-build-steps.png)

    The "Manage Sauce Credentials" step sets environment variables for your Sauce Labs username and access key.

    The "Set Sauce Variables" powershell step corresponds to the `saucelabs-integration.ps1` file in this repo.  This script sets the Sauce Labs "build" and "name" capabilities to the environment variable "SAUCE_BUILD_NAME" and it replaces the ${SAUCE_USERNAME} and ${SAUCE_ACCESS_KEY} tokens with the corresponding environment variables.  It injects those variables into every \settings\external\execution\*\com.kms.katalon.core.webui.remote.properties* file in the Katalon project.  These files are json files that contain the Sauce Labs desired capabilities that were configured in the first step.  The script opens each file, converts it to a Json object, sets all of the environment variables, then saves the file.

* To run the Katalon test, make sure Katalon Studio is installed on the build agent.
* The "Run Katalon Tests" step runs Katalon from the command line.  Note that the -consoleLog flag is not included.  I've found that when that flag is included, the log will not be written to the build console.

    `"C:\Program Files (x86)\Katalon\Katalon_Studio_Windows_64-5.6.3\katalon.exe"
-noSplash -runMode=console -projectPath="%BUILD_SOURCESDIRECTORY%\E2E.prj" -retry=0 -testSuiteCollectionPath="Test Suites/Smoke Suite"`

Note that we are running a test suite collection, which needs to be preconfigured with a Profile and the Sauce Labs desired capabilities we created earlier.
