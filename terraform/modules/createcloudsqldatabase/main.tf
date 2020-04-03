resource "google_sql_database" "create_database" {
  name      = "${var.name}"
  instance  = "${var.instance}"
  charset   = "${var.charset}"
}