resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "google_container_cluster" "gke-cluster" {
  depends_on         = [time_sleep.wait_60_seconds]
  name               = var.name
  network            = var.network
  subnetwork         = var.subnetwork
  location           = var.location
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_allocation_policy {
  }

  private_cluster_config {
    enable_private_endpoint = var.disable_public_endpoint
    enable_private_nodes    = var.enable_private_nodes
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  initial_node_count = 3
}
