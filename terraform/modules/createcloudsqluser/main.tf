resource "random_id" "password" {
  byte_length = 8
}

resource "google_sql_user" "create_user" {
  name     = var.name
  instance = var.instance
  host     = var.host
  password = random_id.password.hex
}
