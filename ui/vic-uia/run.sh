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

# need to download the nightly_ui_tests_secrets.yml file
drone exec --trusted -e test="13-1-VIC-UI-Installer" -E nightly_ui_tests_secrets.yml --yaml ./ui-tests.yml
drone exec --trusted -e test="13-2-VIC-UI-Uninstaller" -E nightly_ui_tests_secrets.yml --yaml ./ui-tests.yml
drone exec --trusted -e test="13-3-VIC-UI-NGC-tests" -E nightly_ui_tests_secrets.yml --yaml ./ui-tests.yml
