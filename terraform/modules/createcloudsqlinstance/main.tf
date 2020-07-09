resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}


resource "google_sql_database_instance" "create_cloud_sql_instance" {
  depends_on = [time_sleep.wait_60_seconds]
  name = var.name
  region = var.region
  database_version = "MYSQL_5_7"
  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled = false
      private_network = var.private_network_link
      require_ssl = true
    }
  }
}


