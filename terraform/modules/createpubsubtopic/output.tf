output "name" {
  value = "${google_pubsub_topic.create_topic.name}"
}

output "id" {
  value = "${google_pubsub_topic.create_topic.id}"
}
