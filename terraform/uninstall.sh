#!/bin/bash

. ../terraform/b-log.sh
LOG_LEVEL_ALL
B_LOG --file patrol-uninstall.log --file-prefix-enable --file-suffix-enable

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
    ERROR "Unable to download the terradorm files"; exit 1
fi

INFO "Fetching the cluster endpoint and auth data of kubernetes cluster"
if gcloud container clusters list  --zone="${PATROL_ZONE}" | awk 'NR>=2' | awk '{print $1}' | grep -wq "${PATROL_KUBERNETES_CLUSTER_NAME}" &> /dev/null;then
    if ! gcloud container clusters get-credentials "${PATROL_KUBERNETES_CLUSTER_NAME}" \
        --zone "${PATROL_ZONE}" --project "${PROJECT_ID}" 2> /dev/null; then
            ERROR "Unable to fetch cluster endpoint and auth "\
                   "data of '${PATROL_KUBERNETES_CLUSTER_NAME}'"; exit 1
    fi

    INFO "Deleting the 'Deployments' of Patrol app .."

    deploy_list=("apiserver" "apistats" "enforcer" "eventtrigger" "fs-server" "patrol-analytics" "ui")

    for name in "${deploy_list[@]}"; do
        if ! kubectl delete deploy $name-deployment &> /dev/null; then
            DEBUG "Deployment: '$name' Not Found"
        fi
    done

    INFO "Deleting the 'Services' of Patrol app .."
    svc_list=("api-server" "enforcer" "fs-restserver" "patrol-analytics")

    for svc in "${svc_list[@]}"; do
        if ! kubectl delete svc patrol-$svc &> /dev/null; then
         DEBUG "Patrol Service: '${svc}' not found"
        fi
    done

    if ! kubectl delete svc $(kubectl get svc | grep 'patrol-webserver') &> /dev/null; then
        DEBUG "Patrol Service: 'webserver' not found"
    fi

    INFO "Deleting the 'Config Maps' of Patrol app .."
    cm_list=("apiserver" "apistats" "cloudsql" "enforcer" "eventtrigger" "fs-server" "patrol-analytics")

    if ! kubectl delete cm patrol-analytics-config &> /dev/null; then
        DEBUG "Patrol Config Map: 'patrol-analytics-config' not found"
    fi

    for cm in "${cm_list[@]}"; do
        if ! kubectl delete cm $cm-config-cm &> /dev/null; then
            DEBUG "Patrol Config Map: '${cm}' not found"
        fi
    done

    INFO "Deleting the 'Secrets' of Patrol app .."
    sr_list=("apiserver" "cloudsql" "enforcer" "eventtrigger" "fs-server")

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

INFO "Destroying the resources created using terraform"

if ! terraform init; then
    ERROR "Failed to initialize the terraform"; exit 1
fi

if ! terraform destroy -var-file=variables.tfvars; then
  ERROR "Unable to perform terraform destroy"; exit 1
fi

INFO "Successfully uninstalled the Patrol Setup"
