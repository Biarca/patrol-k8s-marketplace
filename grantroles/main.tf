module "grant_enforcer_patrol_service_account_project_level_roles" {
  source = "./modules/grantprojectlevelroles"
  roles  = "${var.enforcer_roles_list}"
  email  = "${var.enforcer_service_account_email}"
  resource_type="${var.resource_type}"
  project_id = "${var.project_id}"
}
module "grant_forseti_patrol_service_account_project_level_roles" {
  source = "./modules/grantprojectlevelroles"
  roles  = "${var.forseti_roles_list}"
  email  = "${var.forseti_service_account_email}"
  resource_type="${var.resource_type}"
  project_id = "${var.project_id}"
}

module "grant_apiserver_patrol_service_account_project_level_roles" {
  source = "./modules/grantprojectlevelroles"
  roles  = "${var.apiserver_roles_list}"
  email  = "${var.apiserver_service_account_email}"
  resource_type="${var.resource_type}"
  project_id = "${var.project_id}"
}


module "grant_enforcer_patrol_service_account_folder_level_roles" {
  source = "./modules/grantfolderlevelroles"
  roles  = "${var.enforcer_roles_list}"
  email  = "${var.enforcer_service_account_email}"
  resource_type="${var.resource_type}"
  folder_id = "${var.folder_id}"
}
module "grant_forseti_patrol_service_account_folder_level_roles" {
  source = "./modules/grantfolderlevelroles"
  roles  = "${var.forseti_roles_list}"
  email  = "${var.forseti_service_account_email}"
  resource_type="${var.resource_type}"
  folder_id = "${var.folder_id}"
}

module "grant_apiserver_patrol_service_account_folder_level_roles" {
  source = "./modules/grantfolderlevelroles"
  roles  = "${var.apiserver_roles_list}"
  email  = "${var.apiserver_service_account_email}"
  resource_type="${var.resource_type}"
  folder_id = "${var.folder_id}"
}



provider "google" {
  project     = "${var.project_id}"
  credentials = "${var.service_account_key_file}"
  region      = "${var.region}"
}

resource "null_resource" "create_configure_vm_envs" {
      triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.envs_file}
    echo MONITOR_OWNER_SA=${var.service_account_key_file} >> ${var.envs_file}
    EOT
  }
}