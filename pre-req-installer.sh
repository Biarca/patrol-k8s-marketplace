#!/bin/bash
#
pkg_list=("wget" "jq" "curl" "zip" "unzip" "git" "terraform" "gcloud")

#######################################
# Exits the Code if condition not Met
#######################################
function bail() {
  local EXIT_CODE=$1
  shift
  echo "Exiting: $@" >&2
  exit ${EXIT_CODE}
}

#######################################
# Installs terraform version 0.12.3
#######################################
function install_terraform() {

    if ! wget https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_linux_amd64.zip &> /dev/null; then
        bail 1 "Unable to download the terraform from hashicorp"
    fi
    if ! unzip terraform_0.12.3_linux_amd64.zip -d /usr/bin/ &> /dev/null; then
        bail 1 "Unable to configure terraform path"
    fi
    if ! rm -f terraform_0.12.3_linux_amd64.zip &> /dev/null; then
        bail 1 "Failed to delete the downloaded files"
    fi
}

#######################################
# Installs the Gcloud version 253.0.0
#######################################
function install_gcloud() {
    if ! echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &> /dev/null; then
        bail 1 "Unable to add sources list required for gcloud"
    fi
    if !  apt-get install -y apt-transport-https ca-certificates gnupg &> /dev/null; then
        bail 1 "unable to install support packages for gcloud"
    fi
    if ! curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - &> /dev/null; then
        bail 1 "Unable to update packages list"
    fi
    if ! ( apt-get update && apt-get install -y google-cloud-sdk=253.0.0-0 &> /dev/null ); then
        bail 1 "unable to install gcloud package"
    fi
}

############################################
# Updates & Installs packages required
############################################
echo "Updating the packages list .."
if ! ( apt-get update -y &> /dev/null ); then
    bail 1 "Apt failed to update packages list"
fi
echo "Update is Successful."

for pkg in "${pkg_list[@]}"; do
    if [[ "${pkg}" == "terraform" ]]; then
        echo "Checking for the package: '${pkg}'"
        if ! which "${pkg}" &> /dev/null; then
            echo "Package Not Found: Installing .."
            install_terraform
        else
            echo "Package Found: Checking version .."
            tf_ver=$(terraform -v | head -n 1 | tr "v" " " | awk '{print $2}')
            if dpkg --compare-versions "${tf_ver}" gt 0.12.2; then
                echo "Package Version: Supported"
            else
                echo "Package Version: Not Supported. Updating to v0.12.3"
                install_terraform
            fi
        fi
    elif [[ "${pkg}" == "gcloud" ]]; then
        echo "Checking for the package: '${pkg}'"
        if ! which "${pkg}" &> /dev/null; then
            echo "Package Not Found: Installing .."
            install_gcloud
        else
            echo "Package Found: Checking version .."
            gc_ver=$(gcloud -v | grep SDK | awk '{print $4}')
            if dpkg --compare-versions "${gc_ver}" gt 253.0.0; then
                echo "Package Version: Supported"
            else
                echo "Package Version: Not Supported. Updating to v253.0.0"
                install_cloud
            fi
        fi
    else
        if ! which "${pkg}" &> /dev/null; then
            echo "Package Not Found: Installing .."
            if ! apt-get install "${pkg}" -y 1> /dev/null; then
                bail 1 "Failed to install the package: '${pkg}'"
            else
                echo "Package Installation: SUCCESS"
            fi
        else
            echo "Package '${pkg}' Found"
        fi
    fi
done
echo "All Packages are installed successfully."
