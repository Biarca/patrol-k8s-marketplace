#!/usr/bin/env bash

source monitor.envs
monitoring_email=$(jq -r '.client_email' ${MONITOR_OWNER_SA})
monitoring_project_id=$(jq -r '.project_id' ${MONITOR_OWNER_SA})

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

if gcloud auth activate-service-account --key-file=${MONITOR_OWNER_SA} &> /dev/null; then
  print_debug "Removed owner role for '${installer_email}'"
  if ! gcloud projects remove-iam-policy-binding ${monitoring_project_id} --member=serviceAccount:${monitoring_email} --role='roles/owner' &> /dev/null; then
    bail 1 "Unable to removed the owner role for the monitor service account"
  fi
else
  bail 1 "Unable to activate the service account '${monitoring_email}'"
fi

print_debug "Removed the owner role for the monitor service account"
