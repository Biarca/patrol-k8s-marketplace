provider "google" {
  project     = "${var.patrol_projectid}"
  credentials = "${var.patrol_project_owner_serviceaccount_key_file_path}"
  region      = "${var.patrol_project_default_region}"
}

provider "google" {
  project     = "${var.fs_projectid}"
  credentials = "${var.fs_project_owner_serviceaccount_key_file_path}"
  region      = "${var.fs_project_default_region}"
  alias       = "fs"
}

provider "google-beta"{
  project     = "${var.patrol_projectid}"
  credentials = "${var.patrol_project_owner_serviceaccount_key_file_path}"
  region      = "${var.patrol_project_default_region}"
}