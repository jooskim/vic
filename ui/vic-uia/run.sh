#!/bin/bash
# Copyright 2016 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this should be run before running upload-logs.sh

BINTRAY_DOWNLOAD_PATH="https://bintray.com/vmware/vic-repo/download_file?file_path="
SDK_PACKAGE_ARCHIVE="ui-sdk.tar.gz"
VIC_MACHINE_BIN="vic-machine-linux"
VIC_UI_BIN="vic-ui-linux"
ENV_VSPHERE_SDK_HOME="/tmp/sdk/vc_sdk_min"
ENV_FLEX_SDK_HOME="/tmp/sdk/flex_sdk_min"
ROOT=$(pwd)

# to be used later once merged
#rm -rf 13-1-VIC-UI-Installer 13-2-VIC-UI-Uninstaller 13-3-VIC-UI-NGC-tests
#mkdir 13-1-VIC-UI-Installer
#mkdir 13-2-VIC-UI-Uninstaller
#mkdir 13-3-VIC-UI-NGC-tests

#cp bin/$VIC_UI_BIN ui/$VIC_UI_BIN
#tar --warning=no-unknown-keyword -xzf /tmp/$SDK_PACKAGE_ARCHIVE -C /tmp/

#echo "Building plugin"
#ant -f ui/vic-ui/build-deployable.xml -Denv.VSPHERE_SDK_HOME=$ENV_VSPHERE_SDK_HOME -Denv.FLEX_HOME=$ENV_FLEX_SDK_HOME

#drone exec --trusted -e test="robot -C ansi tests/test-cases/Group13-VIC-UI/setup-testbed.robot && robot -C ansi -d 13-1-VIC-UI-Installer tests/test-cases/Group13-VIC-UI/13-1-VIC-UI-Installer.robot" -E nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
#drone exec --trusted -e test="robot -C ansi tests/test-cases/Group13-VIC-UI/setup-testbed.robot && robot -C ansi -d 13-2-VIC-UI-Uninstaller tests/test-cases/Group13-VIC-UI/13-2-VIC-UI-Uninstaller.robot" -E nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
#drone exec --trusted -e test="robot -C ansi tests/test-cases/Group13-VIC-UI/setup-testbed.robot && mvn install -f ui/vic-uia/pom.xml && robot -C ansi -d 13-3-VIC-UI-NGC-tests tests/test-cases/Group13-VIC-UI/13-3-VIC-UI-NGC-tests.robot" -E nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml

# copy logs
# remove 13-* folders
# remove sdk

# following are for local testing only
# clone ui integration tests branch and change working directory to it
#git clone -b ui-integration-tests https://github.com/jooskim/vic vic-ui-branch
#cd vic-ui-branch
#UI_TESTS_BRANCH=$(pwd)

# need to download the nightly_ui_tests_secrets.yml file
rm -rf 13-1-and-2 13-3
mkdir 13-1-and-2
mkdir 13-3

input=$(wget -O - https://vmware.bintray.com/vic-repo |tail -n5 |head -n1 |cut -d':' -f 2 |cut -d'.' -f 3| cut -d'>' -f 2)

echo "Downloading bintray files"
wget -nv https://vmware.bintray.com/vic-repo/$input.tar.gz

rm -rf bin/uit 2>/dev/null
mkdir -p bin/uit

echo "Extracting .tar.gz"
tar xvzf $input.tar.gz -C bin/uit/ --strip 1
cp bin/uit/$VIC_UI_BIN ui/$VIC_UI_BIN
cp bin/uit/$VIC_MACHINE_BIN ui/$VIC_MACHINE_BIN
cp -rf bin/uit/ui/vsphere-client-serenity ui/installer/

echo "Deleting .tar.gz files"
rm $input.tar.gz

drone exec --trusted -e test="cd tests/test-cases/Group13-VIC-UI && robot -C ansi setup-testbed.robot && robot -C ansi -d $ROOT/13-1-and-2 13-1-VIC-UI-Installer.robot 13-2-VIC-UI-Uninstaller.robot" -E $ROOT/ui/vic-uia/nightly_ui_tests_secrets.yml --yaml $ROOT/ui/vic-uia/ui-tests.yml
drone exec --trusted -e test="cd tests/test-cases/Group13-VIC-UI && robot -C ansi setup-testbed.robot && mvn install -f $ROOT/ui/vic-uia/pom.xml && robot -C ansi -d 13-3 13-3-VIC-UI-NGC-tests.robot" -E $ROOT/ui/vic-uia/nightly_ui_tests_secrets.yml --yaml $ROOT/ui/vic-uia/ui-tests.yml

# copy logs
# delete vic-ui-branch
