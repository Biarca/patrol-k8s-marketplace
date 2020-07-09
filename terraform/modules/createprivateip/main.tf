resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "google_compute_global_address" "private_ip_address" {
  depends_on = [time_sleep.wait_60_seconds]
  name          = var.name
  purpose       = "VPC_PEERING"
  address_type = "INTERNAL"
  network       = var.network_self_link
  prefix_length = 24
}