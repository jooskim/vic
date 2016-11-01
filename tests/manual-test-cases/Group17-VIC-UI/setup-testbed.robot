*** Settings ***
Documentation  Set up testbed before running the UI tests
Resource  ../../resources/Util.robot

*** Keywords ***
Check If Nimbus VMs Exist
    # remove testbed-information if it exists
    ${ti_exists}=  Run Keyword And Return Status  OperatingSystem.Should Exist  testbed-information
    Run Keyword Unless  ${ti_exists}  Remove File  testbed-information

    ${nimbus_machines}=  Set Variable  %{NIMBUS_USER}-UITEST-*
    Log To Console  \nFinding Nimbus machines for UI tests
    Open Connection  %{NIMBUS_GW}
    Login  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}

    ${out}=  Execute Command  nimbus-ctl list | grep -i "${nimbus_machines}"
    @{out}=  Split To Lines  ${out}
    ${out_len}=  Get Length  ${out}
    Close connection

    Run Keyword If  ${out_len} == 0  Setup Testbed  ELSE  Load Testbed  ${out}
    Create File  testbed-information  TEST_ESX_NAME=%{TEST_ESX_NAME}\nESX_HOST_IP=%{ESX_HOST_IP}\nESX_HOST_PASSWORD=%{ESX_HOST_PASSWORD}\nTEST_VC_NAME=%{TEST_VC_NAME}\nTEST_VC_IP=%{TEST_VC_IP}\nTEST_URL_ARRAY=%{TEST_URL_ARRAY}\nTEST_USERNAME=%{TEST_USERNAME}\nTEST_PASSWORD=%{TEST_PASSWORD}\nTEST_DATASTORE=datastore1\nEXTERNAL_NETWORK=%{EXTERNAL_NETWORK}\nTEST_TIMEOUT=%{TEST_TIMEOUT}\nGOVC_INSECURE=%{GOVC_INSECURE}\nGOVC_USERNAME=%{GOVC_USERNAME}\nGOVC_PASSWORD=%{GOVC_PASSWORD}\nGOVC_URL=%{GOVC_URL}\n

Load Testbed
    [Arguments]  ${list}
    Log To Console  Retrieving VMs information for UI testing...\n
    Open Connection  %{NIMBUS_GW}
    Login  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    ${len}=  Get Length  ${list}
    :FOR  ${vm}  IN  @{list}
    \  @{vm_items}=  Split String  ${vm}  :
    \  ${is_esx}=  Run Keyword And Return Status  Should Match Regexp  @{vm_items}[1]  (?i)esx
    \  Run Keyword If  ${is_esx}  Extract Esx Info  @{vm_items}  ELSE  Extract Vcsa Info  @{vm_items}
    Close connection

Extract Esx Info
    [Arguments]  @{vm_fields}
    ${vm_name}=  Evaluate  '@{vm_fields}[1]'.strip()
    ${out}=  Execute Command  NIMBUS=@{vm_fields}[0] nimbus-ctl ip ${vm_name} | grep -i ".*: %{NIMBUS_USER}-.*"
    @{out}=  Split String  ${out}  :
    ${vm_ip}=  Evaluate  '@{out}[2]'.strip()
    Set Environment Variable  TEST_ESX_NAME  ${vm_name}
    Set Environment Variable  ESX_HOST_IP  ${vm_ip}
    Set Environment Variable  ESX_HOST_PASSWORD  e2eFunctionalTest

Extract Vcsa Info
    [Arguments]  @{vm_fields}
    ${vm_name}=  Evaluate  '@{vm_fields}[1]'.strip()
    ${out}=  Execute Command  NIMBUS=@{vm_fields}[0] nimbus-ctl ip ${vm_name} | grep -i ".*: %{NIMBUS_USER}-.*"
    @{out}=  Split String  ${out}  :
    ${vm_ip}=  Evaluate  '@{out}[2]'.strip()
    Set Environment Variable  TEST_VC_NAME  ${vm_name}
    Set Environment Variable  TEST_VC_IP  ${vm_ip}
    Set Environment Variable  TEST_URL_ARRAY  ${vm_ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  EXTERNAL_NETWORK  vm-network
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  GOVC_INSECURE  1
    Set Environment Variable  GOVC_USERNAME  Administrator@vsphere.local
    Set Environment Variable  GOVC_PASSWORD  Admin\!23
    Set Environment Variable  GOVC_URL  ${vm_ip}

Setup Testbed
    # deploy an esxi server
    ${esx1}  ${esx1-ip}=  Deploy Nimbus ESXi Server For NGC Testing  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    Set Environment Variable  TEST_ESX_NAME  ${esx1}
    Set Environment Variable  ESX_HOST_IP  ${esx1-ip}
    Set Environment Variable  ESX_HOST_PASSWORD  e2eFunctionalTest

    # deploy a vcsa
    ${vc}  ${vc-ip}=  Deploy Nimbus vCenter Server For NGC Testing  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    Set Environment Variable  TEST_VC_NAME  ${vc}
    Set Environment Variable  TEST_VC_IP  ${vc-ip}

    # create a datacenter
    Log To Console  Create a datacenter on the VC
    ${out}=  Run  govc datacenter.create Datacenter
    Should Be Empty  ${out}

    # make a cluster
    Log To Console  Create a cluster on the datacenter
    ${out}=  Run  govc cluster.create -dc=Datacenter Cluster
    Should Be Empty  ${out}
    ${out}=  Run  govc cluster.change -dc=Datacenter -drs-enabled=true /Datacenter/host/Cluster
    Should Be Empty  ${out}

    # add the esx host to the cluster
    Log To Console  Add ESX host to Cluster
    ${out}=  Run  govc cluster.add -dc=Datacenter -cluster=/Datacenter/host/Cluster -username=root -password=e2eFunctionalTest -noverify=true -hostname=${esx1-ip}
    Should Contain  ${out}  OK

    # create a distributed switch
    Log To Console  Create a distributed switch
    ${out}=  Run  govc dvs.create -dc=Datacenter test-ds
    Should Contain  ${out}  OK

    # make three port groups
    Log To Console  Create three new distributed switch port groups for management and vm network traffic
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=Datacenter -dvs=test-ds management
    Should Contain  ${out}  OK
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=Datacenter -dvs=test-ds vm-network
    Should Contain  ${out}  OK
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=Datacenter -dvs=test-ds network
    Should Contain  ${out}  OK

    # todo: check here for cluster
    # add the esx host to the portgroups
    Log To Console  Add the ESXi hosts to the portgroups
    ${out}=  Run  govc dvs.add -dvs=test-ds -pnic=vmnic1 -host.ip=${esx1-ip} ${esx1-ip}
    Should Contain  ${out}  OK

    Log To Console  Deploy VIC to the VC cluster
    Set Environment Variable  TEST_URL_ARRAY  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  EXTERNAL_NETWORK  vm-network
    Set Environment Variable  TEST_TIMEOUT  30m

Deploy Nimbus ESXi Server For NGC Testing
    [Arguments]  ${user}  ${password}  ${version}=3620759
    ${name}=  Evaluate  'UITEST-ESX-' + str(random.randint(1000,9999))  modules=random
    Log To Console  \nDeploying Nimbus ESXi server: ${name}
    Open Connection  %{NIMBUS_GW}
    Login  ${user}  ${password}

    ${out}=  Execute Command  nimbus-esxdeploy ${name} --disk=48000000 --ssd=24000000 --memory=8192 --nics 2 ${version}
    # Make sure the deploy actually worked
    Should Contain  ${out}  To manage this VM use
    # Now grab the IP address and return the name and ip for later use
    @{out}=  Split To Lines  ${out}
    :FOR  ${item}  IN  @{out}
    \   ${status}  ${message}=  Run Keyword And Ignore Error  Should Contain  ${item}  IP is
    \   Run Keyword If  '${status}' == 'PASS'  Set Suite Variable  ${line}  ${item}
    @{gotIP}=  Split String  ${line}  ${SPACE}
    ${ip}=  Remove String  @{gotIP}[5]  ,

    # Let's set a password so govc doesn't complain
    Remove Environment Variable  GOVC_PASSWORD
    Remove Environment Variable  GOVC_USERNAME
    Set Environment Variable  GOVC_INSECURE  1
    Set Environment Variable  GOVC_URL  root:@${ip}
    ${out}=  Run  govc host.account.update -id root -password e2eFunctionalTest
    Should Be Empty  ${out}
    Log To Console  Successfully deployed new ESXi server - ${user}-${name}
    Close connection
    [Return]  ${user}-${name}  ${ip}

Deploy Nimbus vCenter Server For NGC Testing
    [Arguments]  ${user}  ${password}  ${version}=3634791
    ${name}=  Evaluate  'UITEST-VC-' + str(random.randint(1000,9999))  modules=random
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

*** Test Cases ***
Check Variables
    # Purpose of this test case is to make sure all environment variables are set correctly before the tests can be performed
    # TODO: remove "Run Keyword And Return Status"s and Log statements when online

    ${isset_SHELL}=  Run Keyword And Return Status  Environment Variable Should Be Set  SHELL
    ${isset_DRONE_SERVER}=  Run Keyword And Return Status  Environment Variable Should Be Set  DRONE_SERVER
    ${isset_DRONE_TOKEN}=  Run Keyword And Return Status  Environment Variable Should Be Set  DRONE_TOKEN
    ${isset_NIMBUS_USER}=  Run Keyword And Return Status  Environment Variable Should Be Set  NIMBUS_USER
    ${isset_NIMBUS_PASSWORD}=  Run Keyword And Return Status  Environment Variable Should Be Set  NIMBUS_PASSWORD
    ${isset_NIMBUS_GW}=  Run Keyword And Return Status  Environment Variable Should Be Set  NIMBUS_GW
    ${isset_TEST_DATASTORE}=  Run Keyword And Return Status  Environment Variable Should Be Set  TEST_DATASTORE
    ${isset_TEST_RESOURCE}=  Run Keyword And Return Status  Environment Variable Should Be Set  TEST_RESOURCE
    ${isset_GOVC_INSECURE}=  Run Keyword And Return Status  Environment Variable Should Be Set  GOVC_INSECURE
    Log To Console  \nChecking environment variables
    Log To Console  SHELL ${isset_SHELL}
    Log To Console  DRONE_SERVER ${isset_DRONE_SERVER}
    Log To Console  DRONE_TOKEN ${isset_DRONE_TOKEN}
    Log To Console  NIMBUS_USER ${isset_NIMBUS_USER}
    Log To Console  NIMBUS_PASSWORD ${isset_NIMBUS_PASSWORD}
    Log To Console  NIMBUS_GW ${isset_NIMBUS_GW}
    Log To Console  TEST_DATASTORE ${isset_TEST_DATASTORE}
    Log To Console  TEST_RESOURCE ${isset_TEST_RESOURCE}
    Log To Console  GOVC_INSECURE ${isset_GOVC_INSECURE}
    Should Be True  ${isset_SHELL} and ${isset_DRONE_SERVER} and ${isset_DRONE_TOKEN} and ${isset_NIMBUS_USER} and ${isset_NIMBUS_GW} and ${isset_TEST_DATASTORE} and ${isset_TEST_RESOURCE} and ${isset_GOVC_INSECURE}

Check Nimbus Machines
    Check If Nimbus VMs Exist
