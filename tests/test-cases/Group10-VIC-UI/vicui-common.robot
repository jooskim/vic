*** Settings ***
Documentation  Common keywords used by VIC UI installation & uninstallation test suites
Library  VicUiInstallPexpectLibrary.py

*** Variables ***
${TEST_VC_IP}               FILL_ME
${TEST_VC_USERNAME}         administrator@vsphere.local
${TEST_VC_PASSWORD}         FILL_ME
${TEST_VC_ROOT_PASSWORD}    FILL_ME
${TIMEOUT}                  5 minutes

${SELENIUM_SERVER_IP}       FILL_ME
${SELENIUM_BROWSER}         *firefox
${ESX_HOST_IP}              FILL_ME
${ESX_HOST_PASSWORD}        FILL_ME
${DATACENTER_NAME}          FILL_ME
${CLUSTER_NAME}             FILL_ME
${DATASTORE_TYPE}           NFS
${DATASTORE_NAME}           FILL_ME
${DATASTORE_IP}             FILL_ME
${HOST_DATASTORE_NAME}      FILL_ME

# TODO: following line should be removed when integrating it into the nightly test box
${UI_INSTALLERS_ROOT}       /Users/kjosh/go/src/github.com/vmware/vic/ui/installer

*** Keywords ***
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

Rename Folder
    [Arguments]  ${old}  ${new}
    Move Directory  ${old}  ${new}
    Should Exist  ${new}

Cleanup Installer Environment
    Unset Vcenter Ip
    @{folders}=  OperatingSystem.List Directory  ${UI_INSTALLER_PATH}/..  vsphere-client-serenity*
    Run Keyword If  ('@{folders}[0]' != 'vsphere-client-serenity')  Rename Folder  ${UI_INSTALLER_PATH}/../@{folders}[0]  ${UI_INSTALLER_PATH}/../vsphere-client-serenity

    
