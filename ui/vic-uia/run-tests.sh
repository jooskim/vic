#!/bin/bash -e
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

set -o pipefail

echo "Removing VIC directory if present"
echo "Cleanup logs from previous run"
rm -rf 17-1-VIC-UI-Installer 17-2-VIC-UI-Uninstaller 17-3-VIC-UI-NGC-tests 2>/dev/null
rm -rf *.zip *.log vic_*.tar.gz
for f in $(find ui/vic-uia/ -name "\$*") ; do
    rm $f
done

input=$(wget -O - https://vmware.bintray.com/vic-repo |tail -n5 |head -n1 |cut -d':' -f 2 |cut -d'.' -f 3| cut -d'>' -f 2)
buildNumber=${input:4}

echo "Downloading bintray file $input"
wget https://vmware.bintray.com/vic-repo/$input.tar.gz

mkdir -p bin

echo "Extracting .tar.gz"
tar xvzf $input.tar.gz -C bin/ --strip 1

echo "Deleting .tar.gz vic file"
rm $input.tar.gz

cp bin/vic-ui-linux ui/
cp bin/vic-machine-linux ui/
cp -rf bin/ui/vsphere-client-serenity ui/installer/

drone exec --trusted -e test="cd tests/manual-test-cases/Group17-VIC-UI && robot -C ansi setup-testbed.robot && robot -C ansi -d ../../../17-1-VIC-UI-Installer 17-1-VIC-UI-Installer.robot" -E ui/vic-uia/nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
drone exec --trusted -e test="cd tests/manual-test-cases/Group17-VIC-UI && robot -C ansi setup-testbed.robot && robot -C ansi -d ../../../17-2-VIC-UI-Uninstaller 17-2-VIC-UI-Uninstaller.robot" -E ui/vic-uia/nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
drone exec --trusted -e test="apt-get install -yq maven && cd tests/manual-test-cases/Group17-VIC-UI && robot -C ansi setup-testbed.robot && mvn install -f ../../../ui/vic-uia/pom.xml && robot -C ansi -d ../../../17-3-VIC-UI-NGC-tests 17-3-VIC-UI-NGC-tests.robot" -E ui/vic-uia/nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
