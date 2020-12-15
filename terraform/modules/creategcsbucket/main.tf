resource "google_storage_bucket" "create_gcs_bucket" {
  name     = var.name
  force_destroy = var.force_destroy
}