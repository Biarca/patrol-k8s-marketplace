#!/bin/bash

function print_debug() {
  builtin echo "Info: $@"
}

function print_error() {
  builtin echo "Error: $@" >&2
}

function bail() {
  local EXIT_CODE=$1
  shift
  builtin echo "Exiting: $@" >&2
  exit ${EXIT_CODE}
}

function check_prerequsites() {
    print_debug "################################"
    print_debug "Checking for required packages ..."
    for pkg in "gcloud" "terraform" "jq" "zip"; do
        if ! $(which ${pkg} &> /dev/null);then
            bail 1 "The required package '${pkg}' not exist"
        fi
    done
}

function check_variables(){
    print_debug "################################"
    print_debug "Checking env values..."
    variables=$(grep -o '^[^#]*' ./installer_envs | cut -d "=" -f1)
    for variable in ${variables}; do
        if [[ ${!variable} == "" ]]; then
            bail 1 "'${variable}' value is empty"
        fi

        if [[ ${variable} == "PATROL_STATS_TIME" ]]; then
            if [[ ${!variable} -lt 15 ]];then
                bail 1 "'${variable}' value should be greater than or equal to 15"
            fi
        fi

        if [[ ${variable} == "RANDOM_ID" ]]; then
            if ! [[ $(echo "${!variable}" |awk '{print length}') -eq 4 ]];then
                bail 1 "The length of '${variable}' should be equal to 4"
            fi
        fi
    done
}

function check_file_content(){
    if ! test -s "${PATROL_KEYFILE}";then
        bail 1 "The file path ${PATROL_KEYFILE} given for '${PATROL_KEYFILE}' "\
               "not exist or it has no content"
    fi
}

function enable_apis(){
    print_debug "################################"
    print_debug "Enabling required APIs in installer project..."
    sleep 2
    for variable in "PATROL_KEYFILE" "PATROL_PROJECTID"; do
        if [[ ${!variable} != "" ]]; then
            if ! sed -i "s~${variable}~${!variable}~g" ../enableapis.sh; then
                bail 1 "Unable to replace value of ${variable}"
            fi
        else
            bail 1 "'${variable}' value is empty"
        fi
    done

    if ! bash ../enableapis.sh; then
        bail 1 "Enabling APIs for installer project '${PATROL_PROJECTID}' failed"
    fi
}


function update_variables(){
    print_debug "################################"
    print_debug "Replacing variables in 'variables.tf' ..."
    sleep 2
    variables=$(grep -o '^[^#]*' ./installer_envs | cut -d "=" -f1)
    for variable in ${variables}; do
        if ! sed -i "s~${variable}~${!variable}~g" variables.tf; then
            bail 1 "Unable to replace value of ${variable}"
        fi
    done
}

function terraform_apply(){
    print_debug "################################"
    print_debug "Creating resources using terraform..."
    sleep 2
    if ! terraform init; then
        bail 1 "Unable to initialize terraform"
    fi

    print_debug "################################"
    print_debug "Saving terraform plan output to plan.txt ..."
    sleep 2
    if ! terraform plan -out=plan.txt; then
        bail 1 "Unable to execute terraform plan"
    fi

    print_debug "################################"
    print_debug "Applying terraform..."
    sleep 2
    if ! terraform apply; then
        bail 1 "Unable to execute terraform apply"
    fi
    print_debug "################################"
    print_debug "Successfully created the GCP assets required for Patrol app installation"
}


function create_backup(){
    print_debug "################################"
    print_debug "Creating required config in kubernetes cluster"\
                "'patrol-kube-cluster-${RANDOM_ID}'"

    sleep 2
    if cd ../app-data && bash create_backup.sh; then
        print_debug "Biarca patrol Appication is up and running"
    else
        bail 1 "Failed to run script ${PWD}/create_backup.sh"
    fi
}

print_debug "Installation started at $(date)"
if ! source ./installer_envs; then
    bail 1 "Unable to source './installer_envs' file"
fi
check_prerequsites
check_variables
check_file_content
enable_apis
update_variables
terraform_apply
create_backup
print_debug "Installation Completed Successfully at $(date)"
