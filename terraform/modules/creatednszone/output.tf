output "dns_zone" {
  value = "${google_dns_managed_zone.create_zone.name}"
}
