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

BINTRAY_DOWNLOAD_PATH="https://bintray.com/vmware/vic-repo/download_file?file_path="
SDK_PACKAGE_ARCHIVE="ui-sdk.tar.gz"
VIC_UI_BIN="vic-ui-linux"
ENV_VSPHERE_SDK_HOME="/tmp/sdk/vc_sdk_min"
ENV_FLEX_SDK_HOME="/tmp/sdk/flex_sdk_min"
ROOT=$(pwd)

# have the following installed / ready:
# lib: maven, pexpect
# branch: jooskim/ui-integration-tests
# file: nightly_ui_tests_secrets.yml (to be copied to ui/tests/test-cases/Group13-VIC-UI/)

apt-cache show maven 2> /dev/null 1> /dev/null
if [[ $? -gt 0 ]] ; then apt-get install -yq maven ; fi

pip show pexpect 2> /dev/null 1> /dev/null
if [[ $? -gt 0 ]] ; then pip install pexpect ; fi

git clone -b ui-integration-tests https://github.com/jooskim/vic vic-ui-branch
cd vic-ui-branch

input=$(wget -O - https://vmware.bintray.com/vic-repo |tail -n5 |head -n1 |cut -d':' -f 2 |cut -d'.' -f 3| cut -d'>' -f 2)

echo "Downloading bintray files"
wget -nv https://vmware.bintray.com/vic-repo/$input.tar.gz
wget -nv $BINTRAY_DOWNLOAD_PATH$SDK_PACKAGE_ARCHIVE -O /tmp/$SDK_PACKAGE_ARCHIVE

mkdir bin

echo "Extracting .tar.gz"
tar xvzf $input.tar.gz -C bin/ --strip 1
cp bin/$VIC_UI_BIN ui/$VIC_UI_BIN
tar --warning=no-unknown-keyword -xzf /tmp/$SDK_PACKAGE_ARCHIVE -C /tmp/

echo "Deleting .tar.gz files"
rm $input.tar.gz
rm /tmp/$SDK_PACKAGE_ARCHIVE

echo "Building plugin"
ant -f ui/vic-ui/build-deployable.xml -Denv.VSPHERE_SDK_HOME=$ENV_VSPHERE_SDK_HOME -Denv.FLEX_HOME=$ENV_FLEX_SDK_HOME
mvn install -f ui/vic-uia/pom.xml

cd tests/test-cases/Group13-VIC-UI
mkdir logs

drone exec --trusted -e test="install_tests" -E nightly_ui_tests_secrets.yml --yaml ./ui-tests.yml
drone exec --trusted -e test="13-3-VIC-UI-NGC-tests" -E nightly_ui_tests_secrets.yml --yaml ./ui-tests.yml

# move log files
# tbi

echo "Removing ui-integration-branch branch folder"
cd $ROOT && rm -rf vic-ui-branch
