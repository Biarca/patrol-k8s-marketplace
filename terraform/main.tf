module "create_patrol_custom_role" {
  source        = "./modules/createcustomroles"
  project_id    = "${var.patrol_projectid}"
  fs_project_id = "${var.fs_projectid}"
  ops_id        = "${var.operations_id}"
  ops_perm      = "${var.operations_role_permissions}"
  scan_id       = "${var.scanner_id}"
  scan_perm     = "${var.scanner_role_permissions}"
  enforcer_installer_id = "${var.enforcer_installer_id}"
  enforcer_installer_permissions = "${var.enforcer_role_installer_permissions}"
  enforce_id    = "${var.enforcer_id}"
  enforce_perm  = "${var.enforcer_role_permissions}"
}

module "create_enforcer_service_account" {
  source                       = "./modules/createserviceaccount"
  service_account_id           = "${var.enforcer_service_account_id}"
  service_account_display_name = "${var.enforcer_service_account_name}"
  service_account_project      = "${var.patrol_projectid}"
}

# module "create_fs_service_account" {
#   source                       = "./modules/createserviceaccount"
#   service_account_id           = "${var.fs_service_account_id}"
#   service_account_display_name = "${var.fs_service_account_name}"
#   service_account_project      = "${var.patrol_projectid}"
# }

module "create_opscan_service_account" {
  source                       = "./modules/createserviceaccount"
  service_account_id           = "${var.opscan_service_account_id}"
  service_account_display_name = "${var.opscan_service_account_name}"
  service_account_project      = "${var.patrol_projectid}"
}

# module "create_cloudsql_service_account" {
#   source                       = "./modules/createserviceaccount"
#   service_account_id           = "${var.cloudsql_service_account_id}"
#   service_account_display_name = "${var.cloudsql_service_account_name}"
#   service_account_project      = "${var.patrol_projectid}"
# }

module "create_vpc_network" {
  source = "./modules/createvpcnetwork"
  name   = "${var.patrol_vpc_network_name}"
  region = "${var.patrol_vpc_region_name}"
  router = "${var.patrol_router_name}"
  nat    = "${var.patrol_nat_name}"
}

module "create_enforcer_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_enforcer_service_account.id}"
}

# module "create_fs_service_account_key" {
#   source             = "./modules/createserviceaccountkey"
#   service_account_id = "${module.create_fs_service_account.id}"
# }

module "create_opscan_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_opscan_service_account.id}"
}

# module "create_cloudsql_service_account_key" {
#   source             = "./modules/createserviceaccountkey"
#   service_account_id = "${module.create_cloudsql_service_account.id}"
# }

module "save_enforcer_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_enforcer_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.enforcer_service_account_id}.json"
}

# module "save_fs_service_account_key" {
#   source  = "./modules/savebase64contenttofile"
#   content = "${module.create_fs_service_account_key.content}"
#   path    = "${var.patrol_keys_path}/${var.fs_service_account_id}.json"
# }

module "save_opscan_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_opscan_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.opscan_service_account_id}.json"
}

# module "save_cloudsql_service_account_key" {
#   source  = "./modules/savebase64contenttofile"
#   content = "${module.create_cloudsql_service_account_key.content}"
#   path    = "${var.patrol_keys_path}/${var.cloudsql_service_account_id}.json"
# }

module "grant_enforcer_fs_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles  = "${var.enforcer_fs_roles}"
  email  = "${module.create_enforcer_service_account.email}"
  providers = {
    google = google.fs
  }
}

module "grant_enforcer_patrol_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles  = "${var.enforcer_patrol_roles}"
  email  = "${module.create_enforcer_service_account.email}"
}

# module "grant_fs_fs_service_account_roles" {
#   source = "./modules/grantroletoserviceaccount"
#   roles  = "${var.fs_fs_roles}"
#   email  = "${module.create_fs_service_account.email}"
#   providers = {
#     google = google.fs
#   }
# }

# module "grant_fs_patrol_service_account_roles" {
#   source = "./modules/grantroletoserviceaccount"
#   roles  = "${var.fs_patrol_roles}"
#   email  = "${module.create_fs_service_account.email}"
# }

module "grant_opscan_patrol_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles  = "${var.opscan_patrol_roles}"
  email  = "${module.create_opscan_service_account.email}"
}

module "grant_opscan_fs_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles  = "${var.opscan_fs_roles}"
  email  = "${module.create_opscan_service_account.email}"
  providers = {
    google = google.fs
  }
}

# module "grant_cloudsql_patrol_service_account_roles" {
#   source = "./modules/grantroletoserviceaccount"
#   roles  = "${var.cloudsql_patrol_roles}"
#   email  = "${module.create_cloudsql_service_account.email}"
# }

module "create_patrol_scanner_bucket" {
  source        = "./modules/creategcsbucket"
  name          = "${var.patrol_scanner_bucket_name}"
  force_destroy = "${var.force_destroy_buckets}"
}

module "create_patrol_cai_bucket" {
  source        = "./modules/creategcsbucket"
  name          = "${var.patrol_cai_bucket_name}"
  force_destroy = "${var.force_destroy_buckets}"
}

module "create_patrol_enforcer_pubsub_topic" {
  source = "./modules/createpubsubtopic"
  name   = "${var.enforcer_pubsub_topic}"
}

module "create_patrol_fs_pubsub_topic" {
  source = "./modules/createpubsubtopic"
  name   = "${var.fs_pubsub_topic}"
}

module "create_patrol_enforcer_subscription" {
  source = "./modules/createpubsubtopicsubscription"
  name   = "${var.enforcer_pubsub_topic_subscription}"
  topic  = "${module.create_patrol_enforcer_pubsub_topic.id}"
}

module "create_patrol_fs_subscription" {
  source = "./modules/createpubsubtopicsubscription"
  name   = "${var.fs_pubsub_topic_subscription}"
  topic  = "${module.create_patrol_fs_pubsub_topic.id}"
}

module "create_private_ip" {
  source            = "./modules/createprivateip"
  name              = "${var.cloudsql_private_ip_name}"
  network_self_link = "https://www.googleapis.com/compute/v1/projects/${var.patrol_projectid}/global/networks/${var.cloud_sql_instance_network}"
  providers = {
    google = google-beta
  }
}

module "createservicenetworkingconnection" {
  source                  = "./modules/createservicenetworkingconnection"
  network                 = "${module.create_private_ip.network_link}"
  reserved_peering_ranges = ["${module.create_private_ip.name}"]
  providers = {
    google = google-beta
  }
}

module "create_patrol_cloudsql_instance" {

  source               = "./modules/createcloudsqlinstance"
  name                 = "${var.cloud_sql_instance_name}"
  region               = "${var.cloud_sql_instance_region}"
  tier                 = "${var.cloud_sql_instance_tier}"
  private_network_link = "${module.createservicenetworkingconnection.network_link}"
  providers = {
    google = google-beta
  }
}

module "create_patrol_apiserver_user" {
  source   = "./modules/createcloudsqluser"
  name     = "${var.patrol_apiserver_user}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
  host     = "${var.patrol_apiserver_cloudsql_host}"
}

module "create_patrol_fs_user" {
  source   = "./modules/createcloudsqluser"
  name     = "${var.patrol_fs_user}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
  host     = "${var.patrol_fs_cloudsql_host}"
}
module "create_patrol_apiserver_database" {
  source   = "./modules/createcloudsqldatabase"
  name     = "${var.patrol_apiserver_cloudsql_database}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
}

module "create_patrol_fs_database" {
  source   = "./modules/createcloudsqldatabase"
  name     = "${var.patrol_fs_cloudsql_database}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
}

# module "create_event_trigger_serviceaccount" {
#   source                       = "./modules/createserviceaccount"
#   service_account_id           = "${var.event_trigger_service_account_name}"
#   service_account_display_name = "${var.event_trigger_service_account_name}"
#   service_account_project      = "${var.patrol_projectid}"
# }

# module "grant_roles_to_event_trigger_serviceaccount" {
#   source = "./modules/grantroletoserviceaccount"
#   roles  = "${var.event_trigger_service_account_roles}"
#   email  = "${module.create_event_trigger_serviceaccount.email}"
# }

# module "create_eventtrigger_service_account_key" {
#   source             = "./modules/createserviceaccountkey"
#   service_account_id = "${module.create_event_trigger_serviceaccount.id}"
# }

# module "save_eventtrigger_service_account_key" {
#   source  = "./modules/savebase64contenttofile"
#   content = "${module.create_eventtrigger_service_account_key.content}"
#   path    = "${var.patrol_keys_path}/${var.eventtrigger_service_account_id}.json"
# }

module "create_event_trigger_topic" {
  source = "./modules/createpubsubtopic"
  name   = "${var.event_trigger_topic_name}"
}

module "create_event_trigger_subscription" {
  source = "./modules/createpubsubtopicsubscription"
  name   = "${var.event_trigger_subscription_name}"
  topic  = "${module.create_event_trigger_topic.id}"
}

module "create_kubernetes_cluster" {
  source                  = "./modules/createkubernetescluster"
  name                    = "${var.patrol_gke_cluster_name}"
  network                 = "${module.create_vpc_network.network}"
  subnetwork              = "${var.patrol_gke_subnetwork}"
  location                = "${var.patrol_compute_instance_zone}"
  machine_type            = "${var.patrol_compute_instance_machine_type}"
  disable_public_endpoint = "${var.disable_public_endpoint}"
  master_ipv4_cidr_block  = "${var.master_ipv4_cidr_block}"
  enable_private_nodes    = "${var.enable_private_nodes}"
}

