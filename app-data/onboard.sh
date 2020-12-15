#!/bin/bash

# Logging
. ./b-log.sh
LOG_LEVEL_ALL
tmst=$(date '+%Y-%m-%d-%H-%M-%S')
B_LOG --file ./arca-onboard-$tmst.log --file-prefix-enable --file-suffix-enable


RANDOM_ID="RANDOMID"
INSTALLER_PROJECT="INSTALLER_PROJ_ID"
INSTALLER_SA="INST_SA"
OPERATIONS_SA="OPER_SA"
ENFORCER_SA="ENF_SA"
SCANNER_PERMISSIONS=SCAN_PERMISSIONS
ENFORCER_MON_PERMISSIONS=ENF_PERMISSIONS
SCANNER_ROLE="SCAN_ROLE"
ENFORCER_ROLE="ENF_ROLE"
KEY_FILE="KFILE"

MONITOR_PROJ_ID="$1"
MEMBER="serviceAccount:${INSTALLER_SA}"
ROLE_OWN="roles/owner"
ROLE_SEC_ADM="roles/iam.securityAdmin"


function onboard(){
    sec_adm=false
    value1=""
    value2=""
    INFO "################################"
    INFO "Configuring the service account ${INSTALLER_SA}"

    if ! gcloud auth activate-service-account ${INSTALLER_SA} \
         --key-file=./${KEY_FILE} &> /dev/null; then
         ERROR "Error while configuring ${INSTALLER_SA}"; exit 1
    else
         INFO "Successfully configured the service account ${INSTALLER_SA}"
    fi
    echo -n "Does the installer service account ${INSTALLER_SA} have roles/owner or roles/iam.securityAdmin persmissions in the monitoring project ${MONITOR_PROJ_ID}? [Y/N]: ";
    read;
    role_cnf=${REPLY}

    if [ ${role_cnf} == 'Y' ]; then
        echo -n "Do you want enforcer functionality for your monitoring project ${MONITOR_PROJ_ID}? [Y/N]: ";
        read;
        enf_cnf=${REPLY}

        INFO "Checking whether ${INSTALLER_SA} service account has valid persmission..."
        if ! gcloud projects get-iam-policy $MONITOR_PROJ_ID \
            --format json | jq -r ".bindings[] | \
            select(.role == \"$ROLE_OWN\").members[] | \
            select(. == \"$MEMBER\")" &> /dev/null; then

            INFO "Error while checking for owner role for ${INSTALLER_SA} under ${MONITOR_PROJ_ID}"; exit 1

        else
            value1=$(gcloud projects get-iam-policy $MONITOR_PROJ_ID \
                --format json | jq -r ".bindings[] | \
                select(.role == \"$ROLE_OWN\").members[] | \
                select(. == \"$MEMBER\")")
        fi

        if [ "$value1" == "" ]; then
            if ! gcloud projects get-iam-policy $MONITOR_PROJ_ID \
                --format json | jq -r ".bindings[] | \
                select(.role == \"$ROLE_SEC_ADM\").members[] | \
                select(. == \"$MEMBER\")" &> /dev/null; then
    
                ERROR "Error while checking for security admin role for ${INSTALLER_SA} under ${MONITOR_PROJ_ID}"; exit 1
            else
                value2=$(gcloud projects get-iam-policy $MONITOR_PROJ_ID \
                    --format json | jq -r ".bindings[] | \
                    select(.role == \"$ROLE_SEC_ADM\").members[] | \
                    select(. == \"$MEMBER\")")
                sec_adm=true
            fi          
        fi

        if [[ "$value1" == "serviceAccount:$INSTALLER_SA" || 
             "$value2" == "serviceAccount:$INSTALLER_SA" ]]; then
          
            if $sec_adm ; then           
                role_admin "add"
            fi
            
            if ! gcloud beta iam roles list --project=${MONITOR_PROJ_ID} \
                --format json | jq -r ".[] | \
                select(.name == \"projects/${MONITOR_PROJ_ID}/roles/${SCANNER_ROLE}\").name" &> /dev/null; then
                ERROR "Unable to fetch the details of projects/${MONITOR_PROJ_ID}/roles/${SCANNER_ROLE}"; exit 1
            else
                scanrole=$(gcloud beta iam roles list --project=${MONITOR_PROJ_ID} \
                --format json | jq -r ".[] | \
                select(.name == \"projects/${MONITOR_PROJ_ID}/roles/${SCANNER_ROLE}\").name")
            fi


            if [[ "${scanrole}" == "" ]]; then
                if ! (y | gcloud beta iam roles create ${SCANNER_ROLE} \
                    --project=${MONITOR_PROJ_ID}  --title=Patrol\ Scanner\ Role \
                    --description="Scanner role of the setup ${RANDOM_ID}" \
                    --stage=GA \
                    --permissions=${SCANNER_PERMISSIONS}) &> /dev/null; then

                    ERROR "Error while creating the custom role projects/${MONITOR_PROJ_ID}/roles/${SCANNER_ROLE}"; exit 1
                else
                   INFO "Patrol Scanner Role created successfully in the project ${MONITOR_PROJ_ID}"
                fi
            fi

            if ! gcloud projects add-iam-policy-binding ${MONITOR_PROJ_ID} \
                 --member=serviceAccount:${OPERATIONS_SA} \
                 --role=projects/$MONITOR_PROJ_ID/roles/${SCANNER_ROLE} \
                 &> /dev/null; then
                 ERROR "Error while binding the role  ${SCANNER_ROLE} in the project ${MONITOR_PROJ_ID}"; exit 1
            else
                INFO "Successfully added ${SCANNER_ROLE} for ${OPERATIONS_SA} in Minitoring Project"
                if ! gcloud projects add-iam-policy-binding \
                    ${MONITOR_PROJ_ID} \
                    --member=serviceAccount:${OPERATIONS_SA} \
                    --role=roles/logging.configWriter &> /dev/null; then
                    ERROR "Error while binding the role roles/logging.configWriter in the project ${MONITOR_PROJ_ID}"; exit 1
                else
                    INFO "Successfully binded roles/logging.configWriter role for ${OPERATIONS_SA} in ${MONITOR_PROJ_ID}"
                fi
            fi         
            
            if [ $enf_cnf == 'Y' ]; then

                if ! gcloud beta iam roles list --project=${MONITOR_PROJ_ID} \
                    --format json | jq -r ".[] | \
                    select(.name == \"projects/${MONITOR_PROJ_ID}/roles/${ENFORCER_ROLE}\").name" &> /dev/null; then
                    ERROR "Unable to fetch the details of projects/${MONITOR_PROJ_ID}/roles/${ENFORCER_ROLE}"; exit 1
                else
                    enfrole=$(gcloud beta iam roles list --project=${MONITOR_PROJ_ID} \
                    --format json | jq -r ".[] | \
                    select(.name == \"projects/${MONITOR_PROJ_ID}/roles/${ENFORCER_ROLE}\").name")
                fi

                if [[ "$enfrole" == "" ]]; then
                    if ! gcloud beta iam roles create ${ENFORCER_ROLE} \
                        --project=${MONITOR_PROJ_ID}  \
                        --title=Patrol\ Monitor\ Enforcer\ Role \
                        --description="Custom enforcer role of the setup ${RANDOM_ID}" \
                        --stage=GA \
                        --permissions=${ENFORCER_MON_PERMISSIONS} \
                        &> /dev/null; then

                        ERROR "Error while creating the custom role ${ENFORCER_ROLE}"; exit 1
                    else
                        INFO "projects/${MONITOR_PROJ_ID}/roles/${ENFORCER_ROLE} created successfully"
                    fi
                fi
                if ! gcloud projects add-iam-policy-binding \
                    ${MONITOR_PROJ_ID} --member=serviceAccount:${ENFORCER_SA} \
                    --role=projects/$MONITOR_PROJ_ID/roles/${ENFORCER_ROLE} \
                    &> /dev/null; then
                    ERROR "Error while binding the role ${ENFORCER_ROLE} in the project ${MONITOR_PROJ_ID}"; exit 1
                else
                    INFO "Successfully binded ${ENFORCER_ROLE} role for ${ENFORCER_SA} in ${MONITOR_PROJ_ID}"
                fi
            elif [ ${enf_cnf} == 'N' ]; then
                INFO "We are not enabling enforcement functionality as you chose."
            else
                ERROR "Enforcer functionality has not been enabled"; exit 1
            fi
            if $sec_adm ; then
                role_admin "del"
            fi
        else
            ERROR "$INSTALLER_SA have no owner and security admin roles in ${MONITOR_PROJ_ID}"; exit 1
        fi
    elif [ ${role_cnf} == 'N' ]; then
        ERROR "Please provide the Onwer or Security Admin role for the installer service account ${INSTALLER_SA}"; exit 1
    else
        ERROR "Only Y or N are acceptable." exit 1
    fi
    
    INFO "${MONITOR_PROJ_ID} successfully added to Biarca Patrol UI"
}

function role_admin(){
    INFO "###############################"
    ROLE=roles/iam.roleAdmin

    if [ $1 == "add" ]; then
        IAM="add-iam-policy-binding"
        TASK="Added"
    else
        IAM="remove-iam-policy-binding"
        TASK="Removed"
    fi
   
    INFO "Assigning RoleAdmin for $INSTALLER_SA in $MONITOR_PROJ_ID"

    if ! gcloud projects $IAM $MONITOR_PROJ_ID --member=serviceAccount:$INSTALLER_SA --role=$ROLE &> /dev/null; then
        INFO "Unable to change roleAdmin for Monitoring project"
    else
        INFO "Successfully '$TASK' Role Admin permissions for $INSTALLER_SA in $MONITOR_PROJ_ID"
    fi
}

onboard

INFO "============================================================="
INFO "Completed the script execution"
INFO "============================================================="

