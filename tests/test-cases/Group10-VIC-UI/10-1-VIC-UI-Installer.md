Test 10-1 - VIC UI Installation
======

#Purpose:
To test all possible installation failures and success scenarios on VCSA 6.0

#References:

#Environment:
* Testing VIC UI requires a working VCSA setup with VCH installed
* Target VCSA has Bash enabled for the root account

#Test Steps:
1. Check if the configs file exists
2. Ensure UI plugin is not registered with VC before testing
3. Try installing UI without the configs file
4. Try installing UI with vsphere-client-serenity folder missing
5. Try installing UI with vCenter IP missing
6. Try installing UI with wrong vCenter credentials
7. Try installing UI with wrong vCenter root password
8. Try installing UI with Bash disabled
9. Install UI successfully without a web server
10. Try installing UI when it is already installed
11. Install UI successfully with the --force flag when the plugin is already registered
12. Try installing UI with a web server and an invalid URL to the plugin zip file

#Expected Outcome:
* Each step should return success

#Possible Problems:
