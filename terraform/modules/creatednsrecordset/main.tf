resource "google_dns_record_set" "create_record_set" {
  name = "${var.name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.managed_zone}"

  rrdatas = ["${var.ip}"]
}