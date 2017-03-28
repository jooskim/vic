#!/bin/bash
# Copyright 2017 VMware, Inc. All Rights Reserved.
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

cleanup () {
    unset VCENTER_ADMIN_USERNAME
    unset VCENTER_ADMIN_PASSWORD
}

# check for the configs file
if [[ ! -f "configs" ]] ; then
    echo "Error! Configs file is missing. Please try downloading the VIC UI installer again"
    echo ""
    cleanup
    exit 1
fi

# load configs variables into env
CONFIGS_FILE="configs"
while IFS='' read -r line; do
    eval $line
done < $CONFIGS_FILE

# check for the VC IP
if [[ $VCENTER_IP == "" ]] ; then
    echo "Error! vCenter IP cannot be empty. Please provide a valid IP in the configs file"
    cleanup
    exit 1
fi

# check for the plugin manifest file
if [[ ! -f ../plugin-manifest ]] ; then
    echo "Error! Plugin manifest was not found!"
    cleanup
    exit 1
fi

# load plugin manifest into env
while IFS='' read -r p_line; do
    eval "$p_line"
done < ../plugin-manifest

read -p "Enter your vCenter Administrator Username: " VCENTER_ADMIN_USERNAME
echo -n "Enter your vCenter Administrator Password: "
read -s VCENTER_ADMIN_PASSWORD
echo ""
read -p "Plugin to Install (flex/html5): " plugin_type

OS=$(uname)
PLUGIN_BUNDLES=''
VCENTER_SDK_URL="https://${VCENTER_IP}/sdk/"
COMMONFLAGS="--target $VCENTER_SDK_URL --user $VCENTER_ADMIN_USERNAME --password $VCENTER_ADMIN_PASSWORD"
OLD_PLUGIN_FOLDERS=''
FORCE_INSTALL=''

case $1 in
    "-f")
        COMMONFLAGS="$COMMONFLAGS --force"
        ;;
    "--force")
        COMMONFLAGS="$COMMONFLAGS --force"
        ;;
esac

if [[ $(echo $OS | grep -i "darwin") ]] ; then
    PLUGIN_MANAGER_BIN="../../vic-ui-darwin"
else
    PLUGIN_MANAGER_BIN="../../vic-ui-linux"
fi

if [[ ${VIC_UI_HOST_URL: -1: 1} != "/" ]] ; then
    VIC_UI_HOST_URL="$VIC_UI_HOST_URL/"
fi

check_prerequisite () {
    if [[ $(curl -v --head https://$VCENTER_IP -k 2>&1 | grep -i "could not resolve host") ]] ; then
        echo "Error! Could not resolve the hostname. Please make sure you set VCENTER_IP correctly in the configuration file"
        cleanup
        exit 1
    fi
}

parse_and_register_plugins () {
    # depending on which plugin the user wants to install set key accordingly
    local plugin_flags="--key $key --name $name --version $version --summary $summary --company $company --url $VIC_UI_HOST_URL$key-v$version.zip"

    echo "----------------------------------------"
    echo "Registering vCenter Server Extension..."
    echo "----------------------------------------"

    $PLUGIN_MANAGER_BIN install $COMMONFLAGS $plugin_flags --server-thumbprint "$VIC_UI_HOST_THUMBPRINT"

    if [[ $? > 0 ]] ; then
        echo "-------------------------------------------------------------"
        echo "Error! Could not register plugin with vCenter Server. Please see the message above"
        cleanup
        exit 1
    fi
}

verify_plugin_url() {
    if [[ $plugin_type = "flex" ]] ; then
        echo
        echo Flex Client Plugin selected
        echo
        key=$key_flex
    else
        echo
        echo HTML5 Client Plugin selected
        echo
        key=$key_h5c
    fi

    local PLUGIN_BASENAME=$key-v$version.zip
    local CURL_RESPONSE=$(curl -v --head $VIC_UI_HOST_URL$PLUGIN_BASENAME -k 2>&1)
    local RESPONSE_STATUS=$(echo $CURL_RESPONSE | grep -E "HTTP\/.*\s4\d{2}\s.*")

    if [[ $(echo $CURL_RESPONSE | grep -i "could not resolve host") ]] ; then
        echo "-------------------------------------------------------------"
        echo "Error! Could not resolve the host provided. Please make sure the URL is correct"
        cleanup
        exit 1

    elif [[ ! $(echo $RESPONSE_STATUS | wc -w) -eq 0 ]] ; then
        echo "-------------------------------------------------------------"
        echo "Error! Plugin was not found in the web server. Please make sure you have uploaded \"$PLUGIN_BASENAME\" to \"$VIC_UI_HOST_URL\", and retry installing the plugin"
        cleanup
        exit 1
    fi
}

check_prerequisite
verify_plugin_url
parse_and_register_plugins

cleanup

echo "--------------------------------------------------------------"
echo "VIC UI registration was successful"
echo ""
