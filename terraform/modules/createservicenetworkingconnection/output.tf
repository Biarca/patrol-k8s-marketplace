output "network_link" {
  value = "${google_service_networking_connection.private_vpc_connection.network}"
}
