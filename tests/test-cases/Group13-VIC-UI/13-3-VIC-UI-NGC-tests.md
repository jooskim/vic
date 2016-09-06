Test 13-3 - VIC UI NGC Tests
======

#Purpose:
To test user interactions with VIC UI in vSphere Web Client

#References:

#Environment:
* Testing VIC UI requires a working VCSA setup with VCH installed

#Test Steps:
1. Check if provider properties files exist
2. Ensure UI plugin is already registered with VC before testing
3. Run the NGC tests
  - Test 1: Verify if the VIC UI plugin is installed correctly
    - Open a browser
    - Log in as admin user
    - Navigate to Administration -> Client Plug-Ins
    - Verify if item “VicUI” exists

  - Test 2.1: Verify if VCH VM Portlet exists
    - Open a browser
    - Log in as admin user
    - Navigate to the VCH VM Summary tab
    - Verify if property id `dockerApiEndpoint` exists

  - Test 2.2: Verify if VCH VM Portlet displays correct information while VM is OFF
    - Ensure the vApp is off
    - Open a browser
    - Log in as admin user
    - Navigate to the VCH VM Summary tab
    - Verify if `dockerApiEndpoint` equals the placeholder value `-`

  - Test 2.3: Verify if VCH VM Portlet displays correct information while VM is ON
    - Ensure the vApp is on
    - Open a browser
    - Log in as admin user
    - Navigate to the VCH VM Summary tab
    - Verify if `dockerApiEndpoint` does not equal the placeholder value `-`

  - Test 3: Verify if Container VM Portlet exists
    - Open a browser
    - Log in as admin user
    - Navigate to the Container VM Summary tab
    - Verify if property id `containerName` exists

#Expected Outcome:
* Each step should return success

#Possible Problems:
NGC automated testing is not available on VC 5.5, so if the tests were to run against a box with VC 5.5 Step 3 above would be skipped. However, you can manually run the NGC tests by following the steps above.
