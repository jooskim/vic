*** Settings ***
Documentation  Common keywords used by VIC UI installation & uninstallation test suites
Resource  ../../resources/Util.robot
Library  VicUiInstallPexpectLibrary.py

*** Variables ***
# TODO: these values will be replaced by the time a PR is submitted. most of these values will be populated at runtime
${TEST_VC_VERSION}          6.0
${TEST_VC_IP}               10.17.109.132
${TEST_VC_USERNAME}         administrator@vsphere.local
${TEST_VC_PASSWORD}         ca\$hc0w
${TEST_VC_ROOT_PASSWORD}    ca\$hc0w
${TIMEOUT}                  5 minutes

${SELENIUM_SERVER_IP}       10.162.122.138
${SELENIUM_SERVER_PORT}     4444
${SELENIUM_BROWSER}         *firefox
${ESX_HOST_IP}              10.17.109.167
${ESX_HOST_PASSWORD}        ca\$hc0w
${DATACENTER_NAME}          Datacenter
${CLUSTER_NAME}             Cluster
${DATASTORE_TYPE}           NFS
${DATASTORE_NAME}           fake
${DATASTORE_IP}             1.1.1.1
${HOST_DATASTORE_NAME}      DStore
${VCH_VM_NAME}              vic_5728
${CONTAINER_VM_NAME}        sharp_feynman-d39db0a231f2f639a073814c2affc03e4737d9ad361649069eb424e6c4e09b52

*** Keywords ***
Set Absolute Script Paths
    # TODO: Since Docker environment is always Linux, it would be impossible to directly test the Windows script in the Drone CI system. Rather, the test could be done manually on Windows
    ${UI_INSTALLERS_ROOT}=  Run  pwd
    ${UI_INSTALLERS_ROOT}=  Join Path  ${UI_INSTALLERS_ROOT}  ../../../ui/installer
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
    # Populate VCENTER_IP with ${TEST_VC_IP}
    Remove File  ${UI_INSTALLER_PATH}/configs
    ${results}=  Replace String Using Regexp  ${configs}  VCENTER_IP=.*  VCENTER_IP=\"${TEST_VC_IP}\"
    ${results2}=  Run Keyword If  ${TEST_VC_VERSION} == '5.5'  Replace String Using Regexp  ${results}  IS_VCENTER_5_5=.*  IS_VCENTER_5_5=1  ELSE  Set Variable  ${results}

    Create File  ${UI_INSTALLER_PATH}/configs  ${results2}
    ${check}=  OperatingSystem.Get File  ${UI_INSTALLER_PATH}/configs
    Should Contain  ${check}  ${TEST_VC_IP}

Unset Vcenter Ip
    # Revert the configs file back to what it was
    #Remove File  ${UI_INSTALLER_PATH}/configs
    ${results}=  Replace String Using Regexp  ${configs}  VCENTER_IP=.*  VCENTER_IP=\"\"
    ${results}=  Replace String Using Regexp  ${results}  IS_VCENTER_5_5=.*  IS_VCENTER_5_5=0
    #Generate Config  ${UI_INSTALLER_PATH}/configs  '${results}'
    Run  echo '${results}' > ${UI_INSTALLER_PATH}/configs
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
    # Reverts the configs file and make sure the folder containing the UI binaries has its original name that might've been left modified due to a test failure
    Unset Vcenter Ip
    @{folders}=  OperatingSystem.List Directory  ${UI_INSTALLER_PATH}/..  vsphere-client-serenity*
    Run Keyword If  ('@{folders}[0]' != 'vsphere-client-serenity')  Rename Folder  ${UI_INSTALLER_PATH}/../@{folders}[0]  ${UI_INSTALLER_PATH}/../vsphere-client-serenity

Setup Testbed
    ${esx1}  ${esx1-ip}=  Deploy Nimbus ESXi Server  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    Set Suite Variable  ${TEST_ESX_NAME}  ${esx1}
    Set Suite Variable  ${ESX_HOST_IP}  ${esx1-ip}
    Set Suite Variable  ${ESX_HOST_PASSWORD}  e2eFunctionalTest
    Set Suite Variable  ${HOST_DATASTORE_NAME}  %{TEST_DATASTORE}

    ${vc}  ${vc-ip}=  Deploy Nimbus vCenter Server For NGC Testing  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    Set Suite Variable  ${TEST_VC_NAME}  ${vc}

    Log To Console  Create a datacenter on the VC
    ${out}=  Run  govc datacenter.create Datacenter
    Should Be Empty  ${out}

    #make a cluster here
    Log To Console  Create a cluster on the datacenter
    ${out}=  Run  govc cluster.create -dc=Datacenter Cluster
    Should Be Empty  ${out}

    Log To Console  Add ESX host to the VC
    ${out}=  Run  govc host.add -hostname=${esx1-ip} -username=root -dc=Datacenter -password=e2eFunctionalTest -noverify=true
    Should Contain  ${out}  OK

    Log To Console  Add ESX host to Cluster
    ${out}=  Run  govc cluster.add -dc=Datacenter -username=root -password=e2eFunctionalTest -noverify=true hostname=${esx1-ip}
    Should Contain  ${out}  OK

    Log To Console  Create a distributed switch
    ${out}=  Run  govc dvs.create -dc=Datacenter test-ds
    Should Contain  ${out}  OK

    Log To Console  Create three new distributed switch port groups for management and vm network traffic
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=Datacenter -dvs=test-ds management
    Should Contain  ${out}  OK
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=Datacenter -dvs=test-ds vm-network
    Should Contain  ${out}  OK

    #check here for cluster
    Log To Console  Add the ESXi hosts to the portgroups
    ${out}=  Run  govc dvs.add -dvs=test-ds -pnic=vmnic1 ${esx1-ip}  
    Should Contain  ${out}  OK

    Log To Console  Deploy VIC to the VC cluster
    Set Environment Variable  TEST_URL_ARRAY  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Suite Variable  ${TEST_VC_PASSWORD}  Admin\!23
    Set Environment Variable  EXTERNAL_NETWORK  vm-network
    Set Environment Variable  TEST_TIMEOUT  30m

    Install VIC Appliance To Test Server  ${false}  default
    Set Suite Variable  ${VCH_VM_NAME}  ${vch-name}

Deploy Nimbus vCenter Server For NGC Testing
    [Arguments]  ${user}  ${password}  ${version}=3634791
    ${name}=  Evaluate  'VC-' + str(random.randint(1000,9999))  modules=random
    Log To Console  \nDeploying Nimbus vCenter server: ${name}
    Open Connection  %{NIMBUS_GW}
    Login  ${user}  ${password}

    ${out}=  Execute Command  nimbus-vcvadeploy --vcvaBuild ${version} --useQaNgc ${name}
    # Make sure the deploy actually worked
    Should Contain  ${out}  Overall Status: Succeeded
    # Now grab the IP address and return the name and ip for later use
    @{out}=  Split To Lines  ${out}
    :FOR  ${item}  IN  @{out}
    \   ${status}  ${message}=  Run Keyword And Ignore Error  Should Contain  ${item}  Cloudvm is running on IP
    \   Run Keyword If  '${status}' == 'PASS'  Set Suite Variable  ${line}  ${item}
    ${ip}=  Fetch From Right  ${line}  ${SPACE}

    Set Environment Variable  GOVC_INSECURE  1
    Set Environment Variable  GOVC_USERNAME  Administrator@vsphere.local
    Set Environment Variable  GOVC_PASSWORD  Admin!23
    Set Environment Variable  GOVC_URL  ${ip}
    Log To Console  Successfully deployed new vCenter server - ${user}-${name}
    Close connection
    [Return]  ${user}-${name}  ${ip}

Destroy Testbed
    Run Keyword And Ignore Error  Kill Nimbus Server  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  ${TEST_ESX_NAME}
    Run Keyword And Ignore Error  Kill Nimbus Server  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  ${TEST_VC_NAME}
