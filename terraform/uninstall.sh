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

print_debug "Fetching the cluster endpoint and auth data of kubernetes cluster"
if gcloud container clusters list  --zone="${PATROL_ZONE}" | awk 'NR>=2' | awk '{print $1}' | grep -wq "${PATROL_KUBERNETES_CLUSTER_NAME}" &> /dev/null;then
  if ! gcloud container clusters get-credentials "${PATROL_KUBERNETES_CLUSTER_NAME}" \
      --zone "${PATROL_ZONE}" --project "${PROJECT_ID}" 2> /dev/null; then
          bail 1 "Unable to fetch cluster endpoint and auth "\
                 "data of '${PATROL_KUBERNETES_CLUSTER_NAME}'"
  fi

  print_debug "Deleting the Deployments of the application - Patrol"

  deploy_list=("apiserver" "apistats" "enforcer" "eventtrigger" "forsetiserver" "grafana" "ui")

 for name in "${deploy_list[@]}"; do
   if ! kubectl delete deploy $name-deployment &> /dev/null; then
     print_debug "Deployment: '$name' Not Found"
   fi
 done

  svc_list=("api-server" "enforcer" "forseti-restserver" "grafana" "webserver-tndr")

 for svc in "${svc_list[@]}"; do
   if ! kubectl delete svc patrol-$svc &> /dev/null; then
     bail 1 "Unable to remove Patrol Service '${svc}'"
   fi
 done

  cm_list=("apiserver" "apistats" "cloudsql" "enforcer" "eventtrigger" "forsetiserver" "grafana")

 if ! kubectl delete cm grafana-config &> /dev/null; then
   bail 1 "Unable to delete the Config Map garfana-config"
 fi

 for cm in "${cm_list[@]}"; do
   if ! kubectl delete cm $cm-config-cm &> /dev/null; then
     bail 1 "Unable to delete the Config Map '${cm}'"
   fi
 done

  sr_list=("apiserver" "cloudsql" "enforcer" "eventtrigger" "forsetiserver")

 if ! kubectl delete secret cloudsql-db-credentials &> /dev/null; then
   bail 1 "Unable to delete the Cloud SQL DB Secrets"
 fi

  for sr in "${sr_list[@]}"; do
    if ! kubectl delete secret $sr-secret-key &> /dev/null; then
      bail 1 "Unable to delete the Secret '${sr}'"
    fi
  done

else
  print_debug "The kubernetes cluster with name "\
              "'${PATROL_KUBERNETES_CLUSTER_NAME}' does not exist "\
              "in the zone '${PATROL_ZONE}'"
fi

sleep 2
print_debug "Destroying the resources created using terraform"
if ! terraform destroy; then
  bail 1 "Unable to perform terraform destroy"
fi

print_debug "Successfully uninstalled the Patrol Setup"
