output "name" {
  value = "${google_sql_user.create_user.name}"
}

output "host" {
  value = "${google_sql_user.create_user.host}"
}

output "password" {
  value = "${google_sql_user.create_user.password}"
}