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

if ! source ../app-data/uninstall.envs; then
    bail 1 "Unable to source 'uninstall.envs' file"
fi

if ! gcloud auth activate-service-account --key-file=${PATROL_OWNER_SA};then
    bail 1 "Unable to activate the service account '${PATROL_OWNER_SA}'"
fi

if ! gcloud config set project ${PROJECT_ID} &> /dev/null; then
    bail 1 "Unable to set gcloud project to '${PATROL_PROJECT_ID}'"
fi

if ! gsutil -m cp -r gs://${SCANNER_BUCKET}/tform/* ./ &> /dev/null; then
    bail 1 "Unable to download the terradorm files"
fi

print_debug "Fetching the cluster endpoint and auth data of kubernetes cluster"
if gcloud container clusters list  --zone="${PATROL_ZONE}" | awk 'NR>=2' | awk '{print $1}' | grep -wq "${PATROL_KUBERNETES_CLUSTER_NAME}" &> /dev/null;then
    if ! gcloud container clusters get-credentials "${PATROL_KUBERNETES_CLUSTER_NAME}" \
        --zone "${PATROL_ZONE}" --project "${PROJECT_ID}" 2> /dev/null; then
            bail 1 "Unable to fetch cluster endpoint and auth "\
                   "data of '${PATROL_KUBERNETES_CLUSTER_NAME}'"
    fi

    print_debug "Deleting the 'Deployments' of Patrol app .."

    deploy_list=("apiserver" "apistats" "enforcer" "eventtrigger" "forsetiserver" "grafana" "ui")

    for name in "${deploy_list[@]}"; do
        if ! kubectl delete deploy $name-deployment &> /dev/null; then
            print_debug "Deployment: '$name' Not Found"
        fi
    done

    print_debug "Deleting the 'Services' of Patrol app .."
    svc_list=("api-server" "enforcer" "forseti-restserver" "grafana")

    for svc in "${svc_list[@]}"; do
        if ! kubectl delete svc patrol-$svc &> /dev/null; then
         print_debug "Patrol Service: '${svc}' not found"
        fi
    done

    if ! kubectl delete svc $(kubectl get svc | grep 'patrol-webserver-') &> /dev/null; then
        print_debug "Patrol Service: 'webserver' not found"
    fi

    print_debug "Deleting the 'Config Maps' of Patrol app .."
    cm_list=("apiserver" "apistats" "cloudsql" "enforcer" "eventtrigger" "forsetiserver" "grafana")

    if ! kubectl delete cm grafana-config &> /dev/null; then
        print_debug "Patrol Config Map: 'grafana' not found"
    fi

    for cm in "${cm_list[@]}"; do
        if ! kubectl delete cm $cm-config-cm &> /dev/null; then
            print_debug "Patrol Config Map: '${cm}' not found"
        fi
    done

    print_debug "Deleting the 'Secrets' of Patrol app .."
    sr_list=("apiserver" "cloudsql" "enforcer" "eventtrigger" "forsetiserver")

    if ! kubectl delete secret cloudsql-db-credentials &> /dev/null; then
        print_debug "Patrol Secret: 'cloudsql-db-creds' not found"
    fi

    for sr in "${sr_list[@]}"; do
        if ! kubectl delete secret $sr-secret-key &> /dev/null; then
            print_debug "Patrol Secret: '${cm}' not found"
        fi
    done

    print_debug "Deleting the 'Ingress' of Patrol app .."
    if ! kubectl delete ingress patrol-ingress &> /dev/null; then
        print_debug "Ingress: 'patrol-ingress' not found"
    fi
else
  print_debug "The kubernetes cluster with name "\
              "'${PATROL_KUBERNETES_CLUSTER_NAME}' does not exist "\
              "in the zone '${PATROL_ZONE}'"
fi

sleep 2
export PATROL_OWNER_SA=${PATROL_OWNER_SA}
export MONITOR_OWNER_SA=${MONITOR_OWNER_SA}

envsubst '$PATROL_OWNER_SA,$MONITOR_OWNER_SA' < ./variables.tfvars.template > variables.tfvars

print_debug "Destroying the resources created using terraform"

if ! terraform init; then
    bail 1 "Failed to initialize the terraform"
fi

if ! terraform destroy -var-file=variables.tfvars; then
  bail 1 "Unable to perform terraform destroy"
fi

print_debug "Successfully uninstalled the Patrol Setup"
