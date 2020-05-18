#!/bin/bash

. ../terraform/b-log.sh
LOG_LEVEL_ALL
B_LOG --file ./terraform/patrol.log --file-prefix-enable --file-suffix-enable

pkg_list=("wget" "jq" "curl" "zip" "unzip" "git" "terraform" "gcloud")

#######################################
# Installs terraform version 0.12.3
#######################################
function install_terraform() {
    INFO "Installing terraform package, please wait.."
    if ! wget https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_linux_amd64.zip &> /dev/null; then
        ERROR "Unable to download the terraform from hashicorp"; exit 1
    fi
    if ! unzip terraform_0.12.3_linux_amd64.zip -d /usr/bin/ &> /dev/null; then
        ERROR "Unable to configure terraform path"; exit 1
    fi
    if ! rm -f terraform_0.12.3_linux_amd64.zip &> /dev/null; then
        ERROR "Failed to delete the downloaded files"; exit 1
    fi
}

#######################################
# Installs the Gcloud version 253.0.0
#######################################
function install_gcloud() {
    INFO "Installing Gcloud package, please wait.."

    if ! echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &> /dev/null; then
        ERROR "Unable to add sources list required for gcloud"; exit 1
    fi
    if !  apt-get install -y apt-transport-https ca-certificates gnupg &> /dev/null; then
        ERROR "unable to install support packages for gcloud"; exit 1
    fi
    if ! curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - &> /dev/null; then
        ERROR "Unable to update packages list"; exit 1
    fi
    if ! ( apt-get update && apt-get install -y google-cloud-sdk=253.0.0-0 &> /dev/null ); then
        ERROR "unable to install gcloud package"; exit 1
    fi
    INFO "gcloud package installation is successful"
}

############################################
# Updates & Installs packages required
############################################

INFO "Updating the packages list .."

if ! ( apt-get update ); then
    DEBUG "Apt failed to update packages list"
fi
INFO "Update is Successful."

for pkg in "${pkg_list[@]}"; do
    if [[ "${pkg}" == "terraform" ]]; then
        INFO "Checking for the package: '${pkg}'"
        if ! which "${pkg}" &> /dev/null; then
            DEBUG "'${pkg}' package not found. Installing .."
            install_terraform
        else
            DEBUG "Package Found: Checking version .."
            tf_ver=$(terraform -v | head -n 1 | tr "v" " " | awk '{print $2}')
            if dpkg --compare-versions "${tf_ver}" eq 0.12.3; then
                INFO "'${pkg}' package Version is Supported"
            else
                ERROR "'${pkg}' package Version is not supported. \
                Uninstall the existing terraform and run the script again"; exit 1
            fi
        fi
    elif [[ "${pkg}" == "gcloud" ]]; then
        INFO "Checking for the package: '${pkg}'"
        if ! which "${pkg}" &> /dev/null; then
            DEBUG "'${pkg}' package not found. Installing .."
            install_gcloud
        else
            DEBUG "'${pkg}' package found. Checking version .."
            gc_ver=$(gcloud -v | grep SDK | awk '{print $4}')
            if dpkg --compare-versions "${gc_ver}" gt 253.0.0; then
                INFO "'${pkg}' package version supported"
            else
                DEBUG "'${pkg}' package version not supported. Updating to v253.0.0"
                install_cloud
            fi
        fi
    else
        if ! which "${pkg}" &> /dev/null; then
            INFO "'${pkg}' package not found. Installing .."
            if ! apt-get install "${pkg}" -y 1> /dev/null; then
                ERROR "Failed to install the '${pkg}' package"; exit 1
            else
                INFO "'${pkg}' package installation is SUCCESSFUL"
            fi
        else
            INFO "Package '${pkg}' Found"
        fi
    fi
done
INFO "All Packages are installed successfully."
