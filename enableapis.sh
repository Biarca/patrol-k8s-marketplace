#!/usr/bin/env bash

installer_key_file=PATROL_KEYFILE
installer_project_id=PATROL_PROJECTID
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
container.googleapis.com
'''


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

# Enable Required API's in Installer project
if gcloud auth activate-service-account --key-file ${installer_key_file}; then
  if gcloud config set project ${installer_project_id} &> /dev/null; then
    print_debug "gcloud config project set to '${installer_project_id}'"
    for api in ${FORSETI_ENABLE_APIS}; do
      if ! gcloud services enable ${api}; then
        bail 1 "Failed to enable API [${api}]."
      fi
    done
  else
    bail 1 "Unable set gcloud project '${installer_project_id}'"
  fi
else
  bail 1 "Unable to activate service account with '${installer_key_file}'"
fi

# Create an app in App Engine in installer project to
# support creating cloud schedulers for monitoring projects.
if ! gcloud app describe &> /dev/null; then
	if ! gcloud app create --region us-central &> /dev/null; then
		bail 1 "Failed to create app in App Engine"
	fi
else
	print_debug "App already created in App Engine for the "\
				"project '${installer_project_id}'"
fi
