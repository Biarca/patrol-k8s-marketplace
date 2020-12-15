resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "google_compute_network" "custom-network" {
  name                    = var.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  depends_on    = [time_sleep.wait_60_seconds]
  name          = var.name
  region        = var.region
  ip_cidr_range = "10.144.0.0/20"
  network       = google_compute_network.custom-network.id
  secondary_ip_range {
    range_name    = "patrol-secondary-range"
    ip_cidr_range = "10.145.0.0/24"
  }
}

resource "google_compute_router" "router" {
  depends_on = [google_compute_subnetwork.network-with-private-secondary-ip-ranges]
  name       = var.router
  region     = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  network    = google_compute_network.custom-network.id
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  depends_on                         = [google_compute_router.router]
  name                               = var.nat
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
