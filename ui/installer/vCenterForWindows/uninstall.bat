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

SET target_vc_packages_path=/vsphere-client/vc-packages/vsphere-client-serenity/
SET utils_path=%parent%utils\
SET vcenter_username=administrator@vsphere.local
SET vcenter_unreg_flags=--url https://%target_vcenter_ip%/sdk/ --username %vcenter_username% --password %vcenter_password% --unregister

IF EXIST _scratch_flags.txt (
    DEL _scratch_flags.txt
)

cd ..\vsphere-client-serenity
FOR /D %%i IN (*) DO (
    "%utils_path%xml.exe" sel -t -o "--key " -v "/pluginPackage/@id" %%i\plugin-package.xml >> ..\vCenterForWindows\_scratch_flags.txt
)

ECHO Unregistering VIC UI Plugins...
FOR /F "tokens=*" %%A IN (..\vCenterForWindows\_scratch_flags.txt) DO (
    IF NOT %%A=="" (
        java -jar "%parent%register-plugin.jar" %vcenter_unreg_flags% %%A
    )
)

cd ..\vCenterForWindows
DEL _scratch_flags.txt

IF %ERRORLEVEL%==9009 (
    ECHO Error: java.exe was not found. Did you install Java?
)

ECHO Done
