output "name" {
  value = "${google_compute_global_address.private_ip_address.name}"
}

output "network_link" {
  value = "${google_compute_global_address.private_ip_address.network}"
}