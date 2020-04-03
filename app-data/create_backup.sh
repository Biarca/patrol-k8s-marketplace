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

if ! source kube-deployment.envs; then
    bail 1 "Unable to source 'kube-deployment.envs' file"
fi

sed -i "s|{ROOT_RESOURCE_ID}|${ROOT_RESOURCE_ID}|g" ../bucket-data/configs/forseti_conf_server.yaml
sed -i "s/CLOUDSQL_DB_PASSWORD/${CLOUDSQL_DB_PASSWORD}/g" datasources.yaml

if ! gcloud auth activate-service-account --key-file=${PATROL_OWNER_SA};then
    bail 1 "Unable to activate the service account '${PATROL_OWNER_SA}'"
fi

if ! gcloud config set project ${PROJECT_ID} &> /dev/null; then
    bail 1 "Unable to set gcloud project to '${PATROL_PROJECT_ID}'"
fi

print_debug "##########################################"
print_debug "Copying default patrol config and rules to GCS bucket '${SCANNER_BUCKET}'..."
if ! gsutil -m cp -r ../bucket-data/configs/forseti_conf_server.yaml \
        gs://${SCANNER_BUCKET}/configs/forseti_conf_server.yaml &> /dev/null; then
    bail 1 "Unable to copy default patrol config files to GCS bucket '${SCANNER_BUCKET}'"
fi

if ! gsutil -m cp -r ../bucket-data/rules/* gs://${SCANNER_BUCKET}/rules/ &> /dev/null; then
    bail 1 "Unable to copy default patrol rules files to GCS bucket '${SCANNER_BUCKET}'"
fi

if ! rm -rf ../bucket-data/* &> /dev/null; then
    bail 1 "Unable to purge the template copy files."
fi

if ! gsutil -m cp -r ./datasources.yaml gs://${SCANNER_BUCKET}/backup/ &> /dev/null; then
    bail 1 "Unable to copy datasources to GCS bucket '${SCANNER_BUCKET}'"
fi

if ! gsutil -m cp -r ./*.envs gs://${SCANNER_BUCKET}/backup/ &> /dev/null; then
    bail 1 "Unable to copy default Patrol files to GCS bucket '${SCANNER_BUCKET}'"
fi

# Encrypt Files
echo "Encrypting a Service key"
if ! gpg --yes --batch --passphrase=patrol-id -c ${PATROL_OWNER_SA} &> /dev/null; then
    bail 1 "Unable to copy the default service account"
fi

for file in ./keys/*.json ; do
    if ! gpg --yes --batch --passphrase=patrol-id -c $file &> /dev/null; then
        bail 1 "Unable to copy the Encrypt service account"
    fi
done ;

if ! gsutil -m cp -r ./keys/*.gpg gs://${SCANNER_BUCKET}/backup/keys &> /dev/null; then
    bail 1 "Unable to copy default Patrol json keys to GCS bucket '${SCANNER_BUCKET}'"
fi

if ! gsutil -m cp -r ${PATROL_OWNER_SA}.gpg gs://${SCANNER_BUCKET}/backup/psa/ &> /dev/null; then
    bail 1 "Unable to copy default patrol SA files to GCS bucket '${SCANNER_BUCKET}'"
fi

if ! rm -rf ${PATROL_OWNER_SA}.gpg ./keys/*.json ./keys/*.gpg &> /dev/null; then
    bail 1 "Unable to Remove the Unwanted Keys"
fi

print_debug "#################################"
print_debug "Please Provide the below Details During Marketplace installation"
print_debug "NAMESPACE: 'default'"
print_debug "RANDOM ID: '${RANDOM_ID}'"
print_debug "STATIC IP NAME: '${STATIC_IP_NAME}'"
print_debug "PATROL DOMAIN NAME: '${PATROL_DOMAIN_NAME}'"
print_debug "SCANNER BUCKET: '${SCANNER_BUCKET}'"
print_debug "---------------------------------"
print_debug "Post Marketplace Installation Steps:"
print_debug "1. Enable IAP without Fail."
print_debug "2. Run the script 'remove_serviceaccount_roles.sh' to remove the roles for the service account."
print_debug "---------------------------------"
print_debug "Infrastructure on GCP has been created successfully."
print_debug "NOTE: Back up the terraform files as it will be needed during uninstallation of Patrol."
print_debug "#################################"
