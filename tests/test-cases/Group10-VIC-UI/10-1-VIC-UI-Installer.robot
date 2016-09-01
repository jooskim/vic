*** Settings ***
Documentation  Test 10-1 - VIC UI Installation
Resource  ../../resources/Util.robot
Resource  ./vicui-common.robot
Test Teardown  Cleanup Installer Environment
#Suite Setup  Install VIC Appliance To Test Server
#Suite Teardown  Cleanup VIC Appliance On Test Server

*** Test Cases ***
Check Configs
    Run Keyword  Do OS Check

Ensure Vicui Plugin Is Not Registered Before Testing
    Set Vcenter Ip
    Run Keyword  Force Remove Vicui Plugin

Attempt To Install With Configs File Missing
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
    Log To Console  Skipping this test, as making three incorrect attempts will lock the root account for a certain amount of time
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

