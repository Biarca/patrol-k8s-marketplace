#!/usr/bin/env bash

. ../terraform/b-log.sh

LOG_LEVEL_ALL
B_LOG --file ../patrol.log --file-prefix-enable --file-suffix-enable

source monitor.envs

monitoring_email=$(jq -r '.client_email' ${MONITOR_OWNER_SA})
monitoring_project_id=$(jq -r '.project_id' ${MONITOR_OWNER_SA})

if gcloud auth activate-service-account --key-file=${MONITOR_OWNER_SA} &> /dev/null; then
  INFO "Removed owner role for '${installer_email}'"
  if ! gcloud projects remove-iam-policy-binding ${monitoring_project_id} --member=serviceAccount:${monitoring_email} --role='roles/owner' &> /dev/null; then
    ERROR "Unable to removed the owner role for the monitor service account"; exit 1
  fi
else
  ERROR "Unable to activate the service account '${monitoring_email}'"; exit 1
fi

INFO "Removed the owner role for the monitor service account"
