*** Settings ***
Documentation  Test 10-3 - VIC UI NGC tests
Resource  ../../resources/Util.robot
Resource  ./vicui-common.robot
#Suite Setup  Install VIC Appliance To Test Server
#Suite Teardown  Cleanup VIC Appliance On Test Server

*** Test Cases ***
Check Prerequisites
    ${pwd}=  Run  pwd
    Should Exist  ${pwd}/../../../ui/vic-uia
    Set Suite Variable  ${NGC_TESTS_PATH}  ${pwd}/../../../ui/vic-uia
    Should Exist  ${NGC_TESTS_PATH}/resources/browservm.properties
    Should Exist  ${NGC_TESTS_PATH}/resources/commonTestbedProvider.properties
    Should Exist  ${NGC_TESTS_PATH}/resources/hostProvider.properties
    Should Exist  ${NGC_TESTS_PATH}/resources/vicEnvProvider.properties

*** Keywords ***
Set Up Testbed Config Files
    Log To Console  TBI...
    # set up common testbed provider, host provider and vicenvprovider configurations here according to the content of vicui-common.robot
