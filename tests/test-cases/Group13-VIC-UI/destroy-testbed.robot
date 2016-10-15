*** Settings ***
Documentation  Destroy testbed after the UI test

*** Test Cases ***
Bye
    Log To Console  Bye world I am destroying the testbed

Destroy Testbed
    Run Keyword And Ignore Error  Kill Nimbus Server  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  ${TEST_ESX_NAME}
    Run Keyword And Ignore Error  Kill Nimbus Server  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  ${TEST_VC_NAME}