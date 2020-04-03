resource "google_compute_global_address" "create_global_static_ip" {
  name = "${var.name}"
}