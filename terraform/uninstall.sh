#!/bin/bash

. ./b-log.sh

LOG_LEVEL_ALL
tmst=$(date '+%Y-%m-%d-%H-%M-%S')
B_LOG --file ./patrol-uninstall-$tmst.log --file-prefix-enable --file-suffix-enable

deploy_list=("apiserver" "apistats" "enforcer" "eventtrigger" "fs-server" "patrol-analytics" "ui")
svc_list=("api-server" "enforcer" "fs-restserver" "patrol-analytics")
cm_list=("apiserver" "apistats" "cloudsql" "enforcer" "eventtrigger" "fs-server" "patrol-analytics")
sr_list=("apiserver" "cloudsql" "enforcer" "eventtrigger" "fs-server")

function install_terraform() {

    INFO "Downloading terraform binary v0.12.26 . ."
    if ! wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip; then
        ERROR "Unable to download the terraform."; exit 1
    fi
    if ! unzip terraform_0.12.26_linux_amd64.zip; then
        ERROR "Failed to extract the package"; exit 1
    fi
    if ! rm -rf terraform_0.12.26_linux_amd64.zip; then
        ERROR "Failed to remove the compressed package"; exit 1
    fi
}

if ! source ../app-data/uninstall.envs; then
    ERROR "Unable to source 'uninstall.envs' file"; exit 1
fi

if ! gcloud auth activate-service-account --key-file=${PATROL_OWNER_SA};then
    ERROR "Unable to activate the service account '${PATROL_OWNER_SA}'"; exit 1
fi

if ! gcloud config set project ${PROJECT_ID} &> /dev/null; then
    ERROR "Unable to set gcloud project to '${PATROL_PROJECT_ID}'"; exit 1
fi

if ! gsutil -m cp -r gs://${SCANNER_BUCKET}/tform/* ./ &> /dev/null; then
    DEBUG "Unable to download the terraform files"
    if ! test -s "terraform.tfstate"; then
        ERROR "No tfstate file found in local. Unable to terraform destroy"; exit 1
    fi
fi

INFO "Fetching the cluster endpoint and auth data of kubernetes cluster"
if gcloud container clusters list  --zone="${PATROL_ZONE}" | awk 'NR>=2' | awk '{print $1}' | grep -wq "${PATROL_KUBERNETES_CLUSTER_NAME}" &> /dev/null;then
    if ! gcloud container clusters get-credentials "${PATROL_KUBERNETES_CLUSTER_NAME}" \
        --zone "${PATROL_ZONE}" --project "${PROJECT_ID}" 2> /dev/null; then
            ERROR "Unable to fetch cluster endpoint and auth "\
                   "data of '${PATROL_KUBERNETES_CLUSTER_NAME}'"; exit 1
    fi

    INFO "Deleting the 'Deployments' of Patrol app .."

    for name in "${deploy_list[@]}"; do
        if ! kubectl delete deploy $name-deployment &> /dev/null; then
            DEBUG "Deployment: '$name' Not Found"
        fi
    done

    INFO "Deleting the 'Services' of Patrol app .."

    for svc in "${svc_list[@]}"; do
        if ! kubectl delete svc patrol-$svc &> /dev/null; then
         DEBUG "Patrol Service: '${svc}' not found"
        fi
    done

    if ! kubectl delete svc $(kubectl get svc | grep 'patrol-webserver') &> /dev/null; then
        DEBUG "Patrol Service: 'webserver' not found"
    fi

    INFO "Deleting the 'Config Maps' of Patrol app .."
    

    if ! kubectl delete cm patrol-analytics-config &> /dev/null; then
        DEBUG "Patrol Config Map: 'patrol-analytics-config' not found"
    fi

    for cm in "${cm_list[@]}"; do
        if ! kubectl delete cm $cm-config-cm &> /dev/null; then
            DEBUG "Patrol Config Map: '${cm}' not found"
        fi
    done

    INFO "Deleting the 'Secrets' of Patrol app .."
    

    if ! kubectl delete secret cloudsql-db-credentials &> /dev/null; then
        DEBUG "Patrol Secret: 'cloudsql-db-creds' not found"
    fi

    for sr in "${sr_list[@]}"; do
        if ! kubectl delete secret $sr-secret-key &> /dev/null; then
            DEBUG "Patrol Secret: '${cm}' not found"
        fi
    done

    INFO "Deleting the 'Ingress' of Patrol app .."
    if ! kubectl delete ingress patrol-ingress &> /dev/null; then
        DEBUG "Ingress: 'patrol-ingress' not found"
    fi
else
  DEBUG "The kubernetes cluster with name "\
              "'${PATROL_KUBERNETES_CLUSTER_NAME}' does not exist "\
              "in the zone '${PATROL_ZONE}'"
fi

sleep 2
export PATROL_OWNER_SA=${PATROL_OWNER_SA}
export MONITOR_OWNER_SA=${MONITOR_OWNER_SA}

envsubst '$PATROL_OWNER_SA,$MONITOR_OWNER_SA' < ./variables.tfvars.template > variables.tfvars

INFO "Verifying for terraform in local"
if ! test -s terraform; then
    DEBUG "No terraform binary found in local. Downloading .."
    install_terraform
fi

INFO "Destroying the resources created using terraform"

if ! ./terraform init; then
    ERROR "Failed to initialize the terraform"; exit 1
fi

if ! ./terraform destroy -var-file=variables.tfvars; then
  ERROR "Unable to perform terraform destroy"; exit 1
fi

INFO "Removing the Patrol network .."
if ! gcloud compute networks subnets delete ${PATROL_NETWORK} --region ${REGION} -q; then
    ERROR "Unable to delete Patrol vpc subnets"; exit 1
fi

if ! gcloud compute networks delete ${PATROL_NETWORK} -q; then
    ERROR "Unable to delete Patrol vpc network"; exit 1
fi

INFO "Deleted the Patrol Network"
INFO "==================================================="
INFO "Patrol Uninstallation is Successful"
INFO "Delete the DNS Record of Patrol Domain Name."
INFO "Release the External IP Address from GCP Project"
INFO "==================================================="
