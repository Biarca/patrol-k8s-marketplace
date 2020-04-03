resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name}"
  purpose       = "VPC_PEERING"
  address_type = "INTERNAL"
  network       = "${var.network_self_link}"
  prefix_length = 24
}