resource "google_container_cluster" "gke-cluster" {
 name               = "${var.name}"
 network            = "${var.network}"
 location           = "${var.location}"
 logging_service    = "logging.googleapis.com"
 monitoring_service = "monitoring.googleapis.com"
 ip_allocation_policy {
 
 }
 node_config {
   machine_type = "${var.machine_type}"
   oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
 }
 initial_node_count       = 3

}
