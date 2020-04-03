#!/usr/bin/env bash

function print_debug() {
  builtin echo "Debug: $@"
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

if ! source ./app-data/uninstall.envs; then
    bail 1 "Unable to source './app-data/uninstall.envs' file"
fi

installer_email=$(jq -r '.client_email' ${PATROL_OWNER_SA})
installer_project_id=$(jq -r '.project_id' ${PATROL_OWNER_SA})
monitoring_email=$(jq -r '.client_email' ${MONITOR_OWNER_SA})
monitoring_project_id=$(jq -r '.project_id' ${MONITOR_OWNER_SA})

if gcloud auth activate-service-account --key-file=${PATROL_OWNER_SA} &> /dev/null; then
  print_debug "Removing owner role for '${installer_email}'..."
  if gcloud projects remove-iam-policy-binding ${installer_project_id} --member=serviceAccount:${installer_email} --role='roles/owner' &> /dev/null ; then
      print_debug "Removed owner role for '${installer_email}'"
      if [ "${installer_email}" != "${monitoring_email}" ]; then
          print_debug "Removing owner role for '${installer_email}'..."
          if gcloud auth activate-service-account --key-file=${MONITOR_OWNER_SA} &> /dev/null; then
              if ! gcloud projects remove-iam-policy-binding ${monitoring_project_id} --member=serviceAccount:${monitoring_email} --role='roles/owner' &> /dev/null; then
                  bail 1 "Unable to remove the owner role for the monitoring service account '${monitoring_email}'"
              fi
              print_debug "Removed the owner role monitor service account '${monitoring_email}'"
          else
              bail 1 "Unable to activate the service account '${monitoring_email}'"
          fi
      fi
  else
      bail 1 "Unable to removed the owner roles for the monitoring service account '${installer_email}'"
  fi
else
    bail 1 "Unable to activate the service account '${installer_email}'"
fi

