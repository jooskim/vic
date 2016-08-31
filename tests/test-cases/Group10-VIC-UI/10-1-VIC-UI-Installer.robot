*** Settings ***
Documentation  Test 10-1 - VIC UI Installation
Resource  ../../resources/Util.robot
Library  VicUiInstallPexpectLibrary.py
Test Teardown  Unset Vcenter Ip
#Suite Setup  Install VIC Appliance To Test Server
#Suite Teardown  Cleanup VIC Appliance On Test Server

*** Variables ***
# TODO: later to be replaced with data in resources/Util.robot
${TEST_VC_IP}             10.17.109.159
${TEST_VC_USERNAME}       administrator@vsphere.local
${TEST_VC_PASSWORD}       ca\$hc0w
${TEST_VC_ROOT_PASSWORD}  ca\$hc0w
${TIMEOUT}                3 minutes

# TODO: following line should be removed when integrating it into the nightly test box
${UI_INSTALLERS_ROOT}  /Users/kjosh/go/src/github.com/vmware/vic/ui/installer

*** Test Cases ***
Check Configs
    Run Keyword  Do OS Check

Ensure Vicui Plugin Is Not Registered Before Testing
    Set Vcenter Ip
    Run Keyword  Force Remove Vicui Plugin

Attempt To Install With Configs File Missing
    #Log To Console  \nTesting the installer script when the configs does not exist...
    Move File  ${UI_INSTALLER_PATH}/configs  ${UI_INSTALLER_PATH}/configs_renamed
    ${rc}  ${output}=  Run And Return Rc And Output  ${INSTALLER_SCRIPT_PATH}
    Run Keyword And Continue On Failure  Should Contain  ${output}  Configs file is missing
    Move File  ${UI_INSTALLER_PATH}/configs_renamed  ${UI_INSTALLER_PATH}/configs

Attempt To Install With Plugin Missing
    Set Vcenter Ip
    Move Directory  ${UI_INSTALLER_PATH}/../vsphere-client-serenity  ${UI_INSTALLER_PATH}/../vsphere-client-serenity-a
    Install Fails At Extension Reg  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}  n
    ${output}=  OperatingSystem.GetFile  install.log
    Run Keyword And Continue On Failure  Should Contain  ${output}  VIC UI plugin bundle was not found
    Move Directory  ${UI_INSTALLER_PATH}/../vsphere-client-serenity-a  ${UI_INSTALLER_PATH}/../vsphere-client-serenity
    Remove File  install.log

Attempt To Install With vCenter IP Missing
    Remove File  ${UI_INSTALLER_PATH}/configs
    ${results}=  Replace String Using Regexp  ${configs}  VCENTER_IP=.*  VCENTER_IP=\"\"
    Create File  ${UI_INSTALLER_PATH}/configs  ${results}
    ${rc}  ${output}=  Run And Return Rc And Output  cd ${UI_INSTALLER_PATH} && ./install.sh
    Run Keyword And Continue On Failure  Should Contain  ${output}  Please provide a valid IP

Attempt To Install With Wrong Vcenter Credentials
    Set Vcenter Ip
    Install Fails At Extension Reg  ${TEST_VC_USERNAME}_nope  ${TEST_VC_PASSWORD}_nope  ${TEST_VC_ROOT_PASSWORD}  n
    ${output}=  OperatingSystem.GetFile  install.log
    Should Contain  ${output}  Cannot complete login due to an incorrect user name or password
    Remove File  install.log

Attempt To Install With Wrong Root Password
    Log To Console  Skipping for now...
    #Set Vcenter Ip
    #Install Vicui Without Webserver  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}_abc  n
    #${output}=  OperatingSystem.GetFile  install.log
    #Should Contain  ${output}  Root password is incorrect
    #Remove File  install.log

Attempt To Install Without Webserver Nor Bash Support
    [Timeout]  ${TIMEOUT}
    Set Vcenter Ip
    Append To File  ${UI_INSTALLER_PATH}/configs  SIMULATE_NO_BASH_SUPPORT=1\n
    Install Vicui Without Webserver Nor Bash  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}  n
    ${output}=  OperatingSystem.GetFile  install.log
    Run Keyword And Continue On Failure  Should Contain  ${output}  Bash shell is required
    Force Remove Vicui Plugin
    Remove File  install.log

Install Successfully Without Webserver
    [Timeout]  ${TIMEOUT}
    Set Vcenter Ip
    Install Vicui Without Webserver  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}  n
    ${output}=  OperatingSystem.GetFile  install.log
    Should Contain  ${output}  was successful
    Remove File  install.log

Attempt To Install When Plugin Is Already Registered
    [Timeout]  ${TIMEOUT}
    Set Vcenter Ip
    Install Fails At Extension Reg  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}  n
    ${output}=  OperatingSystem.GetFile  install.log
    Should Contain  ${output}  is already registered
    Remove File  install.log

Install Successfully Without Webserver Using Force Flag
    [Timeout]  ${TIMEOUT}
    Set Vcenter Ip
    Install Vicui Without Webserver  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}  n  True
    ${output}=  OperatingSystem.GetFile  install.log
    Should Contain  ${output}  was successful
    Remove File  install.log
    Log To Console  Force removing Vicui for next tests...
    Force Remove Vicui Plugin

Attempt To Install With Webserver And Wrong Path To Plugin
    Set Vcenter Ip
    ${intermediate_configs}=  OperatingSystem.GetFile  ${UI_INSTALLER_PATH}/configs
    ${configs_with_fake_vicui_hosturl}=  Replace String Using Regexp  ${intermediate_configs}  VIC_UI_HOST_URL=.*  VIC_UI_HOST_URL=\"http:\/\/this-fake-host\.does-not-exist\"
    Create File  ${UI_INSTALLER_PATH}/configs  ${configs_with_fake_vicui_hosturl}
    Wait Until Created  ${UI_INSTALLER_PATH}/configs
    Install Fails At Extension Reg  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}
    ${output}=  OperatingSystem.GetFile  install.log
    Should Contain  ${output}  Could not resolve the host
    Remove File  install.log

*** Keywords ***
# TODO: These keywords are recurring in Test 10-2. Separate this section into one library robot file

Do OS Check
    # TODO: Since Docker environment is always Linux, it would be impossible to directly test the Windows script in the Drone CI system. Rather, the test could be done manually on Windows
    Run Keyword If  os.sep == '/'  Set Suite Variable  ${UI_INSTALLER_PATH}  ${UI_INSTALLERS_ROOT}/VCSA  ELSE  Set Suite Variable  ${UI_INSTALLER_PATH}  ${UI_INSTALLERS_ROOT}/vCenterForWindows
    Should Exist  ${UI_INSTALLER_PATH}
    ${configs_content}=  OperatingSystem.GetFile  ${UI_INSTALLER_PATH}/configs
    Set Suite Variable  ${configs}  ${configs_content}
    
    # set exact paths for installer and uninstaller scripts
    Set Script Filename  INSTALLER_SCRIPT_PATH  ./install
    Set Script Filename  UNINSTALLER_SCRIPT_PATH  ./uninstall

Set Script Filename
    [Arguments]    ${suite_varname}  ${script_name}
    ${SCRIPT_FILENAME}=  Run Keyword If  os.sep == '/'  Set Variable  ${script_name}.sh  ELSE  Set Variable  ${script_name}.bat
    ${SCRIPT_FILENAME}=  Join Path  ${UI_INSTALLER_PATH}  ${SCRIPT_FILENAME}
    Set Suite Variable  \$${suite_varname}  ${SCRIPT_FILENAME}

Set Vcenter Ip
    Remove File  ${UI_INSTALLER_PATH}/configs
    ${results}=  Replace String Using Regexp  ${configs}  VCENTER_IP=.*  VCENTER_IP=\"${TEST_VC_IP}\"
    Create File  ${UI_INSTALLER_PATH}/configs  ${results}
    Wait Until Created  ${UI_INSTALLER_PATH}/configs
    Should Contain  ${results}  ${TEST_VC_IP}

Unset Vcenter Ip
    Remove File  ${UI_INSTALLER_PATH}/configs
    ${results}=  Replace String Using Regexp  ${configs}  VCENTER_IP=.*  VCENTER_IP=\"\"
    Create File  ${UI_INSTALLER_PATH}/configs  ${results}
    Wait Until Created  ${UI_INSTALLER_PATH}/configs
    Should Exist  ${UI_INSTALLER_PATH}/configs

Force Remove Vicui Plugin
    Uninstall Vicui  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}
    ${output}=  OperatingSystem.GetFile  uninstall.log
    Should Match Regexp  ${output}  (unregistration was successful|failed to find target plugin)
    Remove File  uninstall.log

