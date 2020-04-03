variable "project_id" {
  default ="{project id which biarca patrol will be monitoring}"
}

variable "folder_id" {
  default = "{folder id which biarca patrol will be monitoring}"
}

variable "resource_type" {
  default = "{monitoring resource type folder/project}"
}

variable "service_account_key_file" {
  default = "{path of the serviceaccount key file which biarca patrol will be monitoring}"
}
variable "enforcer_service_account_email" {
  default = "patrol-enforcer@forsetictrl.iam.gserviceaccount.com"
}
variable "forseti_service_account_email" {
  default = "patrol-forseti@forsetictrl.iam.gserviceaccount.com"
}
variable "apiserver_service_account_email" {
  default = "patrol-apiserver@forsetictrl.iam.gserviceaccount.com"
}

variable "region" {
  default = "us-central1"
}

variable "enforcer_roles_list" {
  default = ["roles/cloudsql.admin","roles/compute.securityAdmin","roles/iam.securityAdmin","roles/storage.admin"]
}

variable "forseti_roles_list" {
  default = ["roles/appengine.appViewer","roles/bigquery.metadataViewer","roles/browser","roles/cloudasset.viewer","roles/cloudsql.viewer","roles/compute.networkViewer","roles/iam.securityReviewer","roles/orgpolicy.policyViewer","roles/servicemanagement.quotaViewer","roles/serviceusage.serviceUsageConsumer","roles/logging.logWriter","roles/storage.objectViewer"]

}

variable "apiserver_roles_list" {
  default = ["roles/logging.configWriter"]
}

variable "envs_file" {
  default = "monitor.envs"
}
