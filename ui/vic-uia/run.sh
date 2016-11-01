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

# this should be run before running upload-logs.sh

set -o pipefail

rm -rf 13-1-VIC-UI-Installer 13-2-VIC-UI-Uninstaller 13-3-VIC-UI-NGC-tests 2>/dev/null
mkdir 13-1-VIC-UI-Installer
mkdir 13-2-VIC-UI-Uninstaller
mkdir 13-3-VIC-UI-NGC-tests

# todo: need to have the nightly_ui_tests_secrets.yml file at ui/vic-uia/
cp bin/vic-ui-linux ui/
cp bin/vic-machine-linux ui/
cp -rf bin/ui/vsphere-client-serenity ui/installer/

drone exec --trusted -e test="cd tests/test-cases/Group13-VIC-UI && robot -C ansi setup-testbed.robot && robot -C ansi -d ../../../13-1-VIC-UI-Installer 13-1-VIC-UI-Installer.robot" -E ui/vic-uia/nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
drone exec --trusted -e test="cd tests/test-cases/Group13-VIC-UI && robot -C ansi setup-testbed.robot && robot -C ansi -d ../../../13-2-VIC-UI-Uninstaller 13-2-VIC-UI-Uninstaller.robot" -E ui/vic-uia/nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
drone exec --trusted -e test="cd tests/test-cases/Group13-VIC-UI && robot -C ansi setup-testbed.robot && mvn install -f ../../../ui/vic-uia/pom.xml && robot -C ansi -d ../../../13-3-VIC-UI-NGC-tests 13-3-VIC-UI-NGC-tests.robot" -E ui/vic-uia/nightly_ui_tests_secrets.yml --yaml ui/vic-uia/ui-tests.yml
