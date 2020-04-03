provider "google" {
  project     = "${var.patrol_projectid}"
  credentials = "${var.patrol_project_owner_serviceaccount_key_file_path}"
  region      = "${var.patrol_project_default_region}"
}

provider "google" {
  project     = "${var.forseti_projectid}"
  credentials = "${var.forseti_project_owner_serviceaccount_key_file_path}"
  region      = "${var.forseti_project_default_region}"
  alias       = "forseti"
}

provider "google-beta"{
  project     = "${var.patrol_projectid}"
  credentials = "${var.patrol_project_owner_serviceaccount_key_file_path}"
  region      = "${var.patrol_project_default_region}"
}