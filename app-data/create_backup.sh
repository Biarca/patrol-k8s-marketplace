#!/bin/bash

. ../terraform/b-log.sh

LOG_LEVEL_ALL
B_LOG --file ../terraform/patrol.log --file-prefix-enable --file-suffix-enable

if ! source kube-deployment.envs; then
    ERROR "Unable to source 'kube-deployment.envs' file"; exit 1
fi

sed -i "s|{ROOT_RESOURCE_ID}|${ROOT_RESOURCE_ID}|g" ../bucket-data/configs/forseti_conf_server.yaml
sed -i "s/CLOUDSQL_DB_PASSWORD/${CLOUDSQL_DB_PASSWORD}/g" datasources.yaml

if ! gcloud auth activate-service-account --key-file=${PATROL_OWNER_SA};then
    ERROR "Unable to activate the service account '${PATROL_OWNER_SA}'"; exit 1
fi

if ! gcloud config set project ${PROJECT_ID} &> /dev/null; then
    ERROR "Unable to set gcloud project to '${PATROL_PROJECT_ID}'"; exit 1
fi

INFO "##########################################"
INFO "Copying default patrol config and rules to GCS bucket '${SCANNER_BUCKET}'..."
if ! gsutil -m cp -r ../bucket-data/configs/forseti_conf_server.yaml \
        gs://${SCANNER_BUCKET}/configs/forseti_conf_server.yaml &> /dev/null; then
    ERROR "Unable to copy default patrol config files to GCS bucket '${SCANNER_BUCKET}'"; exit 1
else
     INFO "Copying of Patrol config files to the bucket is successful"
fi

if ! gsutil -m cp -r ../bucket-data/rules/* gs://${SCANNER_BUCKET}/rules/ &> /dev/null; then
    ERROR "Unable to copy default patrol rules files to GCS bucket '${SCANNER_BUCKET}'"; exit 1
else
    INFO "Copying of Patrol rule files to the bucket is successful"
fi

if ! rm -rf ../bucket-data/* &> /dev/null; then
    ERROR "Unable to purge the template copy files"; exit 1
fi

if ! gsutil -m cp -r ./datasources.yaml gs://${SCANNER_BUCKET}/backup/ &> /dev/null; then
    ERROR "Unable to copy datasources to GCS bucket '${SCANNER_BUCKET}'"; exit 1
fi
INFO "Copying of datasources to the bucket is successful"

if ! gsutil -m cp -r ./*.envs gs://${SCANNER_BUCKET}/backup/ &> /dev/null; then
    ERROR "Unable to copy default Patrol files to GCS bucket '${SCANNER_BUCKET}'"; exit 1
fi

# Encrypt Files
INFO "Encrypting a Service key"
if ! gpg --yes --batch --passphrase=patrol-id -c ${PATROL_OWNER_SA} &> /dev/null; then
    ERROR "Unable to copy the default service account"; exit 1
fi

for file in ./keys/*.json ; do
    if ! gpg --yes --batch --passphrase=patrol-id -c $file &> /dev/null; then
        ERROR "Unable to copy the Encrypt service account"; exit 1
    fi
done 
INFO "Encryption of Service Keys is successful"

########################################
# Backup the Required files
########################################

INFO  "Copying the required terraform files to the bucket .."

if ! gsutil -m cp -r ./keys/*.gpg gs://${SCANNER_BUCKET}/backup/keys &> /dev/null; then
    ERROR "Unable to copy default Patrol json keys to GCS bucket '${SCANNER_BUCKET}'"; exit 1
fi

if ! gsutil -m cp -r ${PATROL_OWNER_SA}.gpg gs://${SCANNER_BUCKET}/backup/psa/ &> /dev/null; then
    ERROR "Unable to copy default patrol SA files to GCS bucket '${SCANNER_BUCKET}'"; exit 1
fi

if ! gsutil -m cp -r ../terraform/variables.tf gs://${SCANNER_BUCKET}/tform/ &> /dev/null; then
    ERROR "Failed to copy the required terraform files"; exit 1
fi

if ! gsutil -m cp -r ../terraform/*.tfstate gs://${SCANNER_BUCKET}/tform/ &> /dev/null; then
    ERROR "Unable to copy the terraform tfstate file"; exit 1
fi

INFO "Copied the terraform files successfully"
########################################
# Remove the Unwanted and Backed Up files
########################################

INFO "Purging all kind of temp files .."
if ! rm -rf ${PATROL_OWNER_SA}.gpg ./keys/*.json ./keys/*.gpg &> /dev/null; then
    ERROR "Unable to Remove the Unwanted Keys"; exit 1
fi

if ! ( rm -rf $(ls *.envs | grep -v "uninstall.envs") &> /dev/null ); then
    ERROR "Failed to delete the envs files"; exit 1
fi
INFO "Purged all temp files"

########################################
#Providing INFO required for Patrol Marketplace Installation
########################################
INFO "##################################################"
INFO "Please Provide the below Details During Marketplace installation"
DEBUG "Kubernetes Cluster: '${PATROL_KUBERNETES_CLUSTER_NAME}'"
DEBUG "RANDOM ID: '${RANDOM_ID}'"
DEBUG "STATIC IP NAME: '${STATIC_IP_NAME}'"
DEBUG "PATROL DOMAIN NAME: '${PATROL_DOMAIN_NAME}'"
DEBUG "SCANNER BUCKET: '${SCANNER_BUCKET}'"
INFO "---------------------------------"
DEBUG " Post Patrol Application successful installlation, Follow the below: "
DEBUG  "Run the script 'remove_serviceaccount_roles.sh' to remove the roles for the service account."
INFO "---------------------------------"
INFO "Infrastructure on GCP has been created successfully."
INFO "##################################################"
