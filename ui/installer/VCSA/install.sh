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

if [[ $VIC_UI_HOST_URL != 'NOURL' ]] ; then
    if [[ ${VIC_UI_HOST_URL:0:5} == 'https' ]] ; then
        COMMONFLAGS="${COMMONFLAGS} --serverThumbprint ${VIC_UI_HOST_THUMBPRINT}"
    elif [[ ${VIC_UI_HOST_URL:0:5} == 'HTTPS' ]] ; then
        COMMONFLAGS="${COMMONFLAGS} --serverThumbprint ${VIC_UI_HOST_THUMBPRINT}"
    fi

    if [[ ${VIC_UI_HOST_URL: -1: 1} != "/" ]] ; then
        VIC_UI_HOST_URL="$VIC_UI_HOST_URL/"
    fi
fi

check_prerequisite () {
    if [[ ! -d ../vsphere-client-serenity ]] ; then
        echo "Error! VIC UI plugin bundle was not found. Please try downloading the VIC UI installer again"
        exit 1
    fi
}

parse_and_register_plugins () {
    for d in ../vsphere-client-serenity/* ; do
        if [[ -d $d ]] ; then
            echo "Reading plugin-package.xml..."
            local plugin_id=$($XML sel -t -v "/pluginPackage/@id" $d/plugin-package.xml)
            local plugin_version=$($XML sel -t -v "/pluginPackage/@version" $d/plugin-package.xml)
            local plugin_flags=$($XML sel -t -o "--key " -v "/pluginPackage/@id" -o " --name \"" -v "/pluginPackage/@name" -o "\" --version " -v "/pluginPackage/@version" -o " --summary \"" -v "/pluginPackage/@description" -o "\" --company \"" -v "/pluginPackage/@vendor" -o "\"" -n $d/plugin-package.xml)
            if [[ ! -d "../vsphere-client-serenity/${plugin_id}-${plugin_version}" ]] ; then
                rename_package_folder $d "../vsphere-client-serenity/$plugin_id-$plugin_version"
            fi

            local plugin_url="$VIC_UI_HOST_URL"
            if [[ $plugin_url != 'NOURL' ]] ; then
                if [[ ! -f "../vsphere-client-serenity/${plugin_id}-${plugin_version}.zip" ]] ; then
                    echo "File ${plugin_id}-${plugin_version}.zip does not exist!"
                    exit 1
                fi
                local plugin_url="$plugin_url$plugin_id-$plugin_version.zip"
            fi

            echo "Registering vCenter Server Extension..."
            # todo
            # This will eventually change so that go command will be used so the command is going to be like:
            # vic-machine register-ui --key $id --name "$name" --summary "$description" --version "$version" --company "VMware" --pluginurl "DUMMY" --showInSolutionManager
    
            java -jar register-plugin.jar $COMMONFLAGS $plugin_flags \
                --pluginurl "$plugin_url"\
                --showInSolutionManager

            # todo
            # once vic-machine register-ui (or something like that) is ready, it has to return 0 for success and any value higher than 0 upon error so that
            # installer can exit with a proper error message
            # one possible situation is when the already registered plugin is being registered again
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

upload_packages () {
    for d in ../vsphere-client-serenity/* ; do
        if [[ -d $d ]] ; then
            PLUGIN_BUNDLES+="$d "
        fi
    done

    echo ""
    echo "Please enter the root password for your machine running VCSA"
    scp -qr $PLUGIN_BUNDLES root@$VCENTER_IP:$WEBCLIENT_PLUGINS_FOLDER
    if [[ $? > 0 ]] ; then
        echo "Error! Could not upload the VIC plugins to the target VCSA"
        exit 1
    fi
}

update_ownership () {
    echo "Updating ownership of the bundles..."
    echo ""
    local PLUGIN_BUNDLES_WITHOUT_PREFIX=$(echo $PLUGIN_BUNDLES | sed 's/\.\.\/vsphere\-client\-serenity\///g')
    echo "Please enter the root password for your machine running VCSA"
    ssh -t root@$VCENTER_IP "cd $WEBCLIENT_PLUGINS_FOLDER; chown -R vsphere-client:users ${PLUGIN_BUNDLES_WITHOUT_PREFIX}"
    if [[ $? > 0 ]] ; then
        echo "Error! Failed to update the ownership of folders. Please manually set them to vsphere-client:users"
        exit 1
    fi
}

# Check if plugin is located properly 
check_prerequisite

# Read from each plugin bundle the plugin-package.xml file and register a vCenter Server Extension based off of it
# Also, rename the folders such that they follow the convention of $PLUGIN_KEY-$PLUGIN_VERSION
parse_and_register_plugins

# if VIC_UI_HOST_URL is NOURL
if [[ $VIC_UI_HOST_URL == "NOURL" ]] ; then
    # Upload the folders to VCSA's vSphere Web Client plugins cache folder
    upload_packages
    # Chown the uploaded folders from root to vsphere-client
    update_ownership
fi

if [[ $? > 0 ]] ; then
    echo "There was a problem in the VIC UI registration process"
    exit 1
else
    echo "VIC UI registration was successful"
    exit 0
fi
