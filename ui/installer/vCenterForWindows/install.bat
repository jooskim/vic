@ECHO OFF
REM Copyright 2016 VMware, Inc. All Rights Reserved.
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM    http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.

SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

FOR /F "tokens=*" %%A IN (configs) DO (
    IF NOT %%A=="" (
        %%A
    )
)

SET utils_path=%parent%utils\
SET vcenter_username=administrator@vsphere.local
SET vcenter_reg_common_flags=--url https://%target_vcenter_ip%/sdk/ --username %vcenter_username% --password %vcenter_password% --pluginurl "NOURL" --showInSolutionManager

IF %sftp_supported% EQU 1 (
    ECHO Copying plugins...
    "%utils_path%winscp.com" /command "open -hostkey=* sftp://%sftp_username%:%sftp_password%@%target_vcenter_ip%" "put ..\vsphere-client-serenity\* %target_vc_packages_path%" "exit"
) ELSE (
    ECHO SFTP not enabled. You have to manually copy the content of \ui\vsphere-client-serenity to %VMWARE_CFG_DIR%\vsphere-client\vc-packages\vsphere-client-serenity
)

IF %ERRORLEVEL% GTR 0 (
    ECHO Error: Failed uploading plugin files! Check the configs file for correct connection credentials
    GOTO:EOF
)

IF EXIST _scratch_flags.txt (
    DEL _scratch_flags.txt
)

cd ..\vsphere-client-serenity
FOR /D %%i IN (*) DO (
    "%utils_path%xml.exe" sel -t -o "--key " -v "/pluginPackage/@id" -o " --name \"" -v "/pluginPackage/@name" -o "\" --version " -v "/pluginPackage/@version" -o " --summary \"" -v "/pluginPackage/@description" -o "\" --company \"" -v "/pluginPackage/@vendor" -o "\"" -n %%i\plugin-package.xml >> ..\vCenterForWindows\_scratch_flags.txt
)

ECHO Registering VIC UI Plugins...
FOR /F "tokens=*" %%A IN (..\vCenterForWindows\_scratch_flags.txt) DO (
    IF NOT %%A=="" (
        java -jar "%parent%register-plugin.jar" %vcenter_reg_common_flags% %%A
    )
)

cd ..\vCenterForWindows
DEL _scratch_flags.txt

IF %ERRORLEVEL%==9009 (
    ECHO Error: java.exe was not found. Did you install Java?
)

ECHO Done