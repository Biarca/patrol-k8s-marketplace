resource "google_dns_managed_zone" "create_zone" {
  name = "${var.name}"
  dns_name = "${var.dns_name}"
}