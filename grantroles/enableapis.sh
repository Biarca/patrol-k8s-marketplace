#!/usr/bin/env bash

monitoring_key_file=<monitoring_key_file>
FORSETI_ENABLE_APIS='''
cloudresourcemanager.googleapis.com
serviceusage.googleapis.com
admin.googleapis.com
appengine.googleapis.com
bigquery-json.googleapis.com
cloudbilling.googleapis.com
compute.googleapis.com
deploymentmanager.googleapis.com
iam.googleapis.com
sqladmin.googleapis.com
sql-component.googleapis.com
cloudfunctions.googleapis.com
pubsub.googleapis.com
logging.googleapis.com
servicenetworking.googleapis.com
dns.googleapis.com
cloudscheduler.googleapis.com
'''

function print_debug() {
  (( DEBUG )) && {
    builtin echo "Debug: $@"
  }
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

# Enable Required API's in Monitoring resource
if gcloud auth activate-service-account --key-file ${monitoring_key_file}; then
  project_list=$(gcloud projects list|awk 'NR>1 {print $1}') 2> /dev/null
  for project in ${project_list}; do
    if gcloud config set project ${project}; then
      print_debug "gcloud config project set to '${project}'"
      for api in ${FORSETI_ENABLE_APIS}; do
        if ! gcloud services enable ${api}; then
          bail 1 "Failed to enable API [${api}]."
        fi
      done
    else
      bail 1 "Unable set gcloud project '${project}'"
    fi
  done
else
  bail 1 "Unable to activate service account with '${monitoring_key_file}'"
fi