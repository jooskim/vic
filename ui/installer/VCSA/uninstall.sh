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

if [[ ! -f "register-plugin.jar" ]] ; then
	echo "Error! Java package register-plugin.jar is missing!"
	echo "Make sure to run this script on the same directory as the package"
	echo ""
	exit 1
fi

if [[ ! -f "configs" ]] ; then
    echo "Error! Configs file is missing. Please try downloading the VIC UI installer again"
    echo ""
    exit 1
fi

CONFIGS_FILE="configs"
while IFS='' read -r line; do
    eval $line
done < $CONFIGS_FILE

echo -n "Enter your vCenter Administrator Password: "
read -s VCENTER_ADMIN_PASSWORD
echo ""

PLUGIN_BUNDLES=''
VCENTER_ADMIN_USERNAME="administrator@vsphere.local"
VCENTER_SDK_URL="https://${VCENTER_IP}/sdk/"
COMMONFLAGS="--url $VCENTER_SDK_URL --username $VCENTER_ADMIN_USERNAME --password $VCENTER_ADMIN_PASSWORD"
WEBCLIENT_PLUGINS_FOLDER="/etc/vmware/vsphere-client/vc-packages/vsphere-client-serenity/"
PLATFORM=$(uname)

if [[ $PLATFORM == "Linux" ]] ; then
    XML="./xml"
else
    XML="./xml-darwin"
fi

parse_and_unregister_plugins () {
    for d in ../vsphere-client-serenity/* ; do
        if [[ -d $d ]] ; then
            echo "Reading plugin-package.xml..."
            local plugin_flags=$($XML sel -t -o "--key " -v "/pluginPackage/@id" $d/plugin-package.xml)
            echo "Unregistering vCenter Server Extension..."
            java -jar register-plugin.jar $COMMONFLAGS $plugin_flags --unregister
        fi
    done
}

rename_package_folder () {
    mv $1 $2
    if [[ $? > 0 ]] ; then
        echo "Error! Could not rename folder"
        exit 1
    fi
}

# Read from each plugin bundle the plugin-package.xml file and register a vCenter Server Extension based off of it
# Also, rename the folders such that they follow the convention of $PLUGIN_KEY-$PLUGIN_VERSION
parse_and_unregister_plugins

if [[ $? > 0 ]] ; then
    echo "There was a problem in the VIC UI unregistration process"
    exit 1
else
    echo "VIC UI unregistration was successful"
    exit 0
fi
