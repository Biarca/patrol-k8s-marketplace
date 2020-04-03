output "email" {
  value = "${google_service_account.create_service_account.email}"
}
output "account_id" {
  value = "${google_service_account.create_service_account.account_id}"
}

output "project" {
  value = "${google_service_account.create_service_account.project}"
}

output "id" {
  value = "${google_service_account.create_service_account.id}"
}
