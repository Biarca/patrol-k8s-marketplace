#!/bin/bash

. ./b-log.sh

LOG_LEVEL_ALL
B_LOG --file patrol.log --file-prefix-enable --file-suffix-enable

LOCATION_LIST=( "us-central" "northamerica-northeast1" "us-west2" "us-west3" "us-west4"
                "us-east1" "us-east4" "southamerica-east1" "europe-west" "europe-west2"
                "europe-west3" "europe-west6" "asia-northeast1" "asia-east2" "asia-south1"
                "asia-northeast2" "asia-northeast3" "australia-southeast1" )

function check_prerequsites() {
    INFO "################################"
    INFO "Checking for required packages ..."
    sleep 2
    if sudo bash ../package-installer.sh; then
        INFO "Pre-Requisites check completed"
    else
        ERROR "Failed the pre-requisite checks"; exit 1
    fi
}

function check_variables(){
    INFO "################################"
    INFO "Checking env values..."

    variables=$(grep -o '^[^#]*' ./installer_envs | cut -d "=" -f1)

    for variable in ${variables}; do
        if [[ ${!variable} == "" ]]; then
            echo $variable
            ERROR "'${variable}' value is empty in 'installer_envs' file"; exit 1
        fi

        if [[ ${variable} == "PATROL_STATS_TIME" ]]; then
            if [[ ${!variable} -lt 15 ]];then
                ERROR "'${variable}' value should be greater than or equal to 15"; exit 1
            fi
        fi

        if [[ ${variable} == "RANDOM_ID" ]]; then
            if ! [[ $(echo "${!variable}" |awk '{print length}') -eq 4 ]];then
                ERROR "The length of '${variable}' should be equal to 4"; exit 1
            fi
        fi

        if [[ ${variable} == "SCHEDULER_REGION" ]]; then
            if [[ ! " ${LOCATION_LIST[@]} " =~ " ${SCHEDULER_REGION} " ]]; then
                ERROR "Scheduler Region provided is not valid. "\
                       "Please Select Region from this URL: https://cloud.google.com/appengine/docs/locations"; exit 1
            fi
        fi
    done
    INFO "env variables have been validated"
}

function check_file_content(){

    if ! test -s "${PATROL_KEYFILE}" ;then
        ERROR "The file path ${PATROL_KEYFILE} given for '${PATROL_KEYFILE}' "\
               "not exist or it has no content"; exit 1
    fi
}

function enable_apis(){
    INFO "################################"
    INFO "Enabling required APIs in installer project..."
    sleep 2
    for variable in "PATROL_KEYFILE" "PATROL_PROJECTID"; do
        if [[ ${!variable} != "" ]]; then
            if ! sed -i "s~${variable}~${!variable}~g" ../enableapis.sh; then
                ERROR "Unable to replace value of ${variable}"; exit 1
            fi
        else
            ERROR "'${variable}' value is empty"; exit 1
        fi
    done

    if ! bash ../enableapis.sh "${SCHEDULER_REGION}"; then
        ERROR "Enabling APIs for installer project '${PATROL_PROJECTID}' failed"; exit 1
    fi
}


function update_variables(){
    INFO "################################"
    INFO "Replacing variables in 'variables.tf' ..."
    sleep 2
    
    path=$(cat installer_envs | grep PATROL_KEYFILE | cut -d "=" -f 2 | rev | cut -d "/" -f 1 | rev)
    echo $path
    
    sed -i "s|PATROL_KEYFILE=.*|PATROL_KEYFILE=$(pwd)\/$path|" ./installer_envs
    sed -i "s|PATROL_KEYFILE|$(pwd)\/$path|" ./variables.tf

    scheduler_region=$(cat installer_envs | grep "SCHEDULER_REGION" | cut -d "=" -f 2)
    sed -i "s~SCHEDULER_REGION~${scheduler_region}~g" variables.tf
    variables=$(grep -o '^[^#]*' ./installer_envs | cut -d "=" -f1)
    for variable in ${variables}; do
        if ! sed -i "s~${variable}~${!variable}~g" variables.tf; then
            ERROR "Unable to replace value of ${variable}"; exit 1
        fi
    done

}

function terraform_apply(){
    INFO "################################"
    INFO "Creating resources using terraform..."
    sleep 2
    if ! terraform init; then
        ERROR "Unable to initialize terraform"; exit 1
    fi

    INFO "################################"
    INFO "Saving terraform plan output to plan.txt ..."
    sleep 2
    if ! terraform plan -out=plan.txt; then
        ERROR "Unable to execute terraform plan"; exit 1
    fi

    INFO "################################"
    INFO "Applying terraform..."
    sleep 2
    if ! terraform apply; then
        ERROR "Unable to execute terraform apply"; exit 1
    fi
    INFO "################################"
    INFO "Successfully created the GCP assets required for Patrol app installation"
}


function create_backup(){
    INFO "################################"
    INFO "Creating required config in kubernetes cluster"\
                "'patrol-kube-cluster-${RANDOM_ID}'"

    sleep 2
    (pushd ../app-data/ 
    if bash create_backup.sh; then
        INFO "Backup of terraform files Completed"
    else
        ERROR "Failed to create backup ${PWD}/create_backup.sh"; exit 1
    fi
    popd)
}

function cleanup(){
    INFO "Cleaning UP.."
    if ! rm -rf ../app-data/patrol.log; then
       ERROR "Clean UP Failed."; exit 1
    fi
}

INFO "============================================================="
INFO "Infrastructure Creation Started"
INFO "============================================================="

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
cleanup
INFO "============================================================="
INFO "Infrastructure Creation Completed Successfully"
INFO "============================================================="
