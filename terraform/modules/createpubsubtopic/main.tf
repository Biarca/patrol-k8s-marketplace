resource "google_pubsub_topic" "create_topic" {
  name = var.name

  labels = {
    "topic" = var.name
  }
}