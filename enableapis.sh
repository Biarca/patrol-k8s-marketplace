#!/usr/bin/env bash

. ../terraform/b-log.sh
LOG_LEVEL_ALL
tmst="${2}"
B_LOG --file ./patrol-installer-$tmst.log --file-prefix-enable --file-suffix-enable

scheduler_region="${1}"
installer_key_file=PATROL_KEYFILE
installer_project_id=PATROL_PROJECTID
FS_ENABLE_APIS='''
cloudresourcemanager.googleapis.com
serviceusage.googleapis.com
admin.googleapis.com
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

# Enable Required API's in Installer project
sudo chown -R $USER ~/.config/gcloud
if gcloud auth activate-service-account --key-file ${installer_key_file}; then
  INFO "gcloud config project setting to '${installer_project_id}'"
  if gcloud config set project ${installer_project_id} &> /dev/null; then
    INFO "Enabling all the required APIS..."
    for api in ${FS_ENABLE_APIS}; do
      if ! gcloud services enable ${api}; then
        ERROR "Failed to enable API [${api}]."; exit 1
      fi
    done
    INFO "All required APIS are enabled"
  else
    ERROR "Unable set gcloud project '${installer_project_id}'"; exit 1
  fi
else
  ERROR "Unable to activate service account with '${installer_key_file}'"; exit 1
fi
