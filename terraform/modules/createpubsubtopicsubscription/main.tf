resource "google_pubsub_subscription" "create_pubsub_topic_subscription" {
  name    = var.name
  topic   = var.topic
  expiration_policy {
    ttl = ""
  }
}