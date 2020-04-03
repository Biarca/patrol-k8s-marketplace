output "content" {
  value     = "${google_service_account_key.serviceaccountkey.private_key}"
  sensitive = true
}
