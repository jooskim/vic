*** Settings ***
Documentation  Test 13-3 - VIC UI NGC tests
Resource  ../../resources/Util.robot
Resource  ./vicui-common.robot
Test Teardown  Clean Up Testbed Config Files
#Suite Setup  Install VIC Appliance To Test Server
#Suite Teardown  Cleanup VIC Appliance On Test Server

*** Test Cases ***
Check Prerequisites
    ${pwd}=  Run  pwd
    Should Exist  ${pwd}/../../../ui/vic-uia
    Set Suite Variable  ${NGC_TESTS_PATH}  ${pwd}/../../../ui/vic-uia

    # check if the files required by the ngc automation tests exist
    Should Exist  ${NGC_TESTS_PATH}/resources/browservm.tpl.properties
    Should Exist  ${NGC_TESTS_PATH}/resources/commonTestbedProvider.tpl.properties
    Should Exist  ${NGC_TESTS_PATH}/resources/hostProvider.tpl.properties
    Should Exist  ${NGC_TESTS_PATH}/resources/vicEnvProvider.tpl.properties

Ensure Vicui Is Installed
    # ensure vicui is installed before running ngc automation tests
    Set Absolute Script Paths
    Set Vcenter Ip
    Install Vicui Without Webserver  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${TEST_VC_ROOT_PASSWORD}  ${TEST_VC_VERSION}  True
    ${output}=  OperatingSystem.GetFile  install.log
    Should Contain  ${output}  was successful
    Remove File  install.log
    Cleanup Installer Environment

Run Ngc Tests Project
    # given the information in vicui-common.robot edit the above properties files
    Set Up Testbed Config Files

    # start runing ngc tests and expect the output does not include words 'BUILD FAILURE'
    #Run Keyword If  '${TEST_VC_VERSION}'=='5.5'  Skip Ngc Tests  ELSE  Start Ngc Tests
    ${container_name}  ${container_id}  ${container_nameid}=  Create And Run Test Container
    Log To Console  container name ${container_nameid}
    Log To Console  existing container vm name ${CONTAINER_VM_NAME}
    Run  docker stop ${container_id}
    Run  docker rm ${container_id}

*** Keywords ***
Set Up Testbed Config Files
    # set up common testbed provider, host provider and vicenvprovider configurations here according to the content of vicui-common.robot
    ${browservm}=  OperatingSystem.GetFile  ${NGC_TESTS_PATH}/resources/browservm.tpl.properties
    ${commontestbed}=  OperatingSystem.GetFile  ${NGC_TESTS_PATH}/resources/commonTestbedProvider.tpl.properties
    ${host}=  OperatingSystem.GetFile  ${NGC_TESTS_PATH}/resources/hostProvider.tpl.properties
    ${vicenv}=  OperatingSystem.GetFile  ${NGC_TESTS_PATH}/resources/vicEnvProvider.tpl.properties

    # create a container and get its name-id
    #${container_name}=  Create And Run Test Container
    #Log To Console  container name ${container_name}

    # make original copies
    Set Suite Variable  ${browservm_original}  ${browser_vm}
    Set Suite Variable  ${commontestbed_original}  ${commontestbed}
    Set Suite Variable  ${host_original}  ${host}
    Set Suite Variable  ${vicenv_original}  ${vicenv}

    # populate browservm props
    ${browservm}=  Replace String Using Regexp  ${browservm}  (?<!\#)testbed\.seleniumServer=.*  testbed\.seleniumServer=${SELENIUM_SERVER_IP}
    ${browservm}=  Replace String Using Regexp  ${browservm}  (?<!\#)testbed\.seleniumServerPort=.*  testbed\.seleniumServerPort=${SELENIUM_SERVER_PORT}
    ${browservm}=  Replace String Using Regexp  ${browservm}  (?<!\#)testbed\.seleniumBrowser=.*  testbed\.seleniumBrowser=${SELENIUM_BROWSER}

    # populate common test provider props
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.datacenter=.*  testbed\.datacenter=${DATACENTER_NAME}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.pass=.*  testbed.pass=${TEST_VC_PASSWORD}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.host=.*  testbed.host=${ESX_HOST_IP}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.name=.*  testbed.name=${TEST_VC_IP}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.vsc\.url=.*  testbed\.vsc\.url=https\:\/\/${TEST_VC_IP}\/vsphere-client\/
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.cluster=.*  testbed\.cluster=${CLUSTER_NAME}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.endpoint=.*  testbed\.endpoint=${TEST_VC_IP}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.datastore\.type=.*  testbed\.datastore\.type=${DATASTORE_TYPE}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.datastore=.*  testbed\.datastore=${DATASTORE_NAME}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.host\.datastore\.name=.*  testbed\.host\.datastore\.name=${HOST_DATASTORE_NAME}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.datastore\.ip=.*  testbed\.datastore\.ip=${DATASTORE_IP}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.host\.password=.*  testbed\.host\.password=${ESX_HOST_PASSWORD}
    ${commontestbed}=  Replace String Using Regexp  ${commontestbed}  (?<!\#)testbed\.user=.*  testbed\.user=${TEST_VC_USERNAME}

    # populate host provider props
    ${host}=  Replace String Using Regexp  ${host}  (?<!\#)testbed\.endpoint=.*  testbed\.endpoint=${ESX_HOST_IP}
    ${host}=  Replace String Using Regexp  ${host}  (?<!\#)testbed\.local\.datastore\.name=.*  testbed\.local\.datastore\.name=${HOST_DATASTORE_NAME}
    ${host}=  Replace String Using Regexp  ${host}  (?<!\#)testbed\.pass=.*  testbed\.pass=${ESX_HOST_PASSWORD}

    # populate vicenv provider props
    ${vicenv}=  Replace String Using Regexp  ${vicenv}  (?<!\#)testbed\.vc_version=.*  testbed\.vc_version=${TEST_VC_VERSION}
    ${vicenv}=  Replace String Using Regexp  ${vicenv}  (?<!\#)testbed\.vch_vm_name=.*  testbed\.vch_vm_name=${VCH_VM_NAME}
    ${vicenv}=  Replace String Using Regexp  ${vicenv}  (?<!\#)testbed\.container_vm_name=.*  testbed\.container_vm_name=${CONTAINER_VM_NAME}
    ${vicenv}=  Replace String Using Regexp  ${vicenv}  (?<!\#)testbed\.user=.*  testbed\.user=${TEST_VC_USERNAME}
    ${vicenv}=  Replace String Using Regexp  ${vicenv}  (?<!\#)testbed\.pass=.*  testbed\.pass=${TEST_VC_PASSWORD}
    ${vicenv}=  Replace String Using Regexp  ${vicenv}  (?<!\#)testbed\.endpoint=.*  testbed\.endpoint=${TEST_VC_IP}

    Create File  ${NGC_TESTS_PATH}/resources/browservm.properties  ${browservm}
    Create File  ${NGC_TESTS_PATH}/resources/commonTestbedProvider.properties  ${commontestbed}
    Create File  ${NGC_TESTS_PATH}/resources/hostProvider.properties  ${host}
    Create File  ${NGC_TESTS_PATH}/resources/vicEnvProvider.properties  ${vicenv}
    Remove Files  ${NGC_TESTS_PATH}/resources/*.tpl.properties

Revert Config Files
    # revert the properties files to their original template files
    Remove Files  ${NGC_TESTS_PATH}/resources/*.properties
    Create File  ${NGC_TESTS_PATH}/resources/browservm.tpl.properties  ${browservm_original}
    Create File  ${NGC_TESTS_PATH}/resources/commonTestbedProvider.tpl.properties  ${commontestbed_original}
    Create File  ${NGC_TESTS_PATH}/resources/hostProvider.tpl.properties  ${host_original}
    Create File  ${NGC_TESTS_PATH}/resources/vicEnvProvider.tpl.properties  ${vicenv_original}

Create And Run Test Container
    ${rc}  ${container_id}=  Run And Return Rc And Output  docker run -d busybox /bin/top
    ${rc}  ${container_name}=  Run And Return Rc And Output  docker inspect ${container_id} | jq '.[0].Name' | sed 's/[\"\/]//g'
    [Return]  ${container_name}  ${container_id}  ${container_name}-${container_id}

Start Ngc Tests
    # run mvn test and make sure tests are successful. timeout is applied inside the custom library not here
    [Timeout]  NONE
    Run Ngc Tests
    ${output}=  OperatingSystem.GetFile  ngc_tests.log
    Should Contain  ${output}  BUILD SUCCESS
    Should Not Contain  ${output}  BUILD FAILURE
    Remove File  ngc_tests.log

Skip Ngc Tests
    Log To Console  Target VC is 5.5 which is not supported by NGC automation test framework. Skipping...

Clean Up Testbed Config Files
    @{files}=  OperatingSystem.List Directory  ${NGC_TESTS_PATH}/resources  *tpl.properties
    ${num_tpl_files}=  Get Length  ${files}
    Run Keyword If  ${num_tpl_files} == 0  Revert Config Files
