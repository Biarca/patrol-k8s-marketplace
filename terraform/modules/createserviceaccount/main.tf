resource "google_service_account" "create_service_account" {
  account_id   = "${var.service_account_id}"
  display_name = "${var.service_account_display_name}"
  project      = "${var.service_account_project}"
}
