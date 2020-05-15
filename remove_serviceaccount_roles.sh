#!/usr/bin/env bash

. ./terraform/b-log.sh
LOG_LEVEL_ALL
B_LOG --file patrol.log --file-prefix-enable --file-suffix-enable

if ! source ./app-data/uninstall.envs; then
    ERROR "Unable to source './app-data/uninstall.envs' file"; exit 1
fi

installer_email=$(jq -r '.client_email' ${PATROL_OWNER_SA})
installer_project_id=$(jq -r '.project_id' ${PATROL_OWNER_SA})
monitoring_email=$(jq -r '.client_email' ${MONITOR_OWNER_SA})
monitoring_project_id=$(jq -r '.project_id' ${MONITOR_OWNER_SA})

if gcloud auth activate-service-account --key-file=${PATROL_OWNER_SA} &> /dev/null; then
  INFO "Removing owner role for '${installer_email}'..."
  if gcloud projects remove-iam-policy-binding ${installer_project_id} --member=serviceAccount:${installer_email} --role='roles/owner' &> /dev/null ; then
      INFO "Removed owner role for '${installer_email}'"
      if [ "${installer_email}" != "${monitoring_email}" ]; then
          INFO "Removing owner role for '${installer_email}'..."
          if gcloud auth activate-service-account --key-file=${MONITOR_OWNER_SA} &> /dev/null; then
              if ! gcloud projects remove-iam-policy-binding ${monitoring_project_id} --member=serviceAccount:${monitoring_email} --role='roles/owner' &> /dev/null; then
                  ERROR "Unable to remove the owner role for the monitoring service account '${monitoring_email}'"; exit 1
              fi
              INFO "Removed the owner role monitor service account '${monitoring_email}'"
          else
              ERROR "Unable to activate the service account '${monitoring_email}'"; exit 1
          fi
      fi
  else
      ERROR "Unable to removed the owner roles for the monitoring service account '${installer_email}'"; exit 1
  fi
else
    ERROR "Unable to activate the service account '${installer_email}'"; exit 1
fi

