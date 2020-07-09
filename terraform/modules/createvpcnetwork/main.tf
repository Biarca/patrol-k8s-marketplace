resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "google_compute_network" "custom-test" {
  name                    = var.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  depends_on = [time_sleep.wait_60_seconds]
  name          = var.name
  region 		= var.region
  ip_cidr_range = "10.144.0.0/20"
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
  	range_name    = "patrol-secondary-range"
  	ip_cidr_range = "10.145.0.0/24"
  }
}

