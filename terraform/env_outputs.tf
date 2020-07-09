output "PATROL_ENFORCER_DETAILED_PERMISSIONS_FILE_PATH" {
  value = "${var.PATROL_ENFORCER_DETAILED_PERMISSIONS_FILE_PATH}"
}

output "PATROL_ENFORCER_GOOGLE_APPLICATION_CREDENTIALS" {
  value = "/keys/${var.enforcer_service_account_id}.json"
}

output "PATROL_ENFORCER_SCANNER_BUCKET" {
  value = "${module.create_patrol_scanner_bucket.name}"
}

output "PATROL_ENFORCER_FS_API_SERVER" {
  value = "${var.PATROL_FS_API_SERVER}"
}

output "PATROL_ENFORCER_ENFORCER_PROJECT" {
  value = "${var.patrol_projectid}"
}

output "PATROL_ENFORCER_ENFORCER_SUBSCRIPTION_NAME" {
  value = "${module.create_patrol_enforcer_subscription.name}"
}

output "PATROL_FS_GOOGLE_APPLICATION_CREDENTIALS"{
    value="/keys/${var.fs_service_account_id}.json"
}

output "PATROL_FS_CLOUDSQLPROXY_SERVICE_HOST" {
  value="${var.PATROL_FS_CLOUDSQLPROXY_SERVICE_HOST}"
}

output "PATROL_FS_BUCKET" {
  value="gs://${module.create_patrol_scanner_bucket.name}"
}

output "PATROL_FS_GCP_ORGANIZATION" {
  value="${var.patrol_fs_gcp_organization}"
}

output "PATROL_FS_PROJECT_ID" {
  value = "${var.patrol_projectid}"
}

output "PATROL_FS_SUBSCRIPTION_NAME" {
  value = "${module.create_patrol_fs_subscription.name}"
}

output "PATROL_FS_SERVER_CONF" {
  value = "${var.PATROL_FS_SERVER_CONF}"
}
output "PATROL_FS_API_SERVER" {
  value = "${var.PATROL_FS_API_SERVER}"
}

output "PATROL_FS_FS_DB_NAME" {
  value = "${module.create_patrol_fs_database.name}"
}

output "PATROL_FS_FS_DB_USERNAME" {
  value = "${module.create_patrol_fs_user.name}"
}

output "PATROL_FS_FS_DB_PASSWORD" {
  value = "${module.create_patrol_fs_user.password}"
}

output "PATROL_APISERVER_SCANNER_TOPIC_NAME" {
  value = "${module.create_patrol_fs_pubsub_topic.name}"
}
output "PATROL_APISERVER_ENFORCER_TOPIC_NAME" {
  value = "${module.create_patrol_enforcer_pubsub_topic.name}"
}

output "PATROL_APISERVER_GOOGLE_APPLICATION_CREDENTIALS" {
  value = "/keys/${var.apiserver_service_account_id}.json"
}

output "PATROL_APISERVER_CLOUDSQLPROXY_SERVICE_HOST" {
  value = "${var.PATROL_APISERVER_CLOUDSQLPROXY_SERVICE_HOST}"
}


output "PATROL_APISERVER_API_BUCKET" {
  value = "${module.create_patrol_scanner_bucket.name}"
}

output "PATROL_APISERVER_CAI_BUCKET" {
  value = "${module.create_patrol_cai_bucket.name}"
}

output "PATROL_APISERVER_SINK_NAME" {
  value = "${var.PATROL_APISERVER_SINK_NAME}"
}

output "PATROL_APISERVER_PROJECT_ID" {
  value = "${var.patrol_projectid}"
}

output "event_trigger_topic_name" {
  value = "${var.event_trigger_topic_name}"
}

output "event_trigger_subscription_name" {
  value = "${var.event_trigger_subscription_name}"
}

output "PATROL_APISERVER_REGION" {
  value = "${var.patrol_apiserver_region}"
}

output "PATROL_APISERVER_FS_API_DB_NAME" {
  value = "${module.create_patrol_apiserver_database.name}"
}

output "PATROL_APISERVER_FS_API_DB_USERNAME" {
  value = "${module.create_patrol_apiserver_user.name}"
}

output "PATROL_APISERVER_FS_API_DB_PASSWORD" {
  value = "${module.create_patrol_apiserver_user.password}"
}

output "PATROL_APISERVER_CAI_EXPORT_ENABLED" {
  value = "${var.PATROL_APISERVER_CAI_EXPORT_ENABLED}"
}


output "PATROL_APISERVER_SENDGRID_API_KEY"{
  value = "${var.PATROL_APISERVER_SENDGRID_API_KEY}"
}

output "PATROL_APISERVER_EMAIL_SENDER" {
  value = "${var.PATROL_APISERVER_EMAIL_SENDER}"
}

output "PATROL_APISERVER_EMAIL_RECIPIENT" {
  value = "${var.PATROL_APISERVER_EMAIL_RECIPIENT}"
}



output "PATROL_FS_REST_SERVER" {
  value = "${var.PATROL_FS_REST_SERVER}"
}

output "PATROL_ENFORCER_SERVER" {
  value = "${var.PATROL_ENFORCER_SERVER}"
}

output "PATROL_APISERVER_RULES_PATH" {
  value = "${var.PATROL_APISERVER_RULES_PATH}"
}

output "PATROL_APISERVER_PUBLIC_IP" {
  value = "${var.PATROL_APISERVER_PUBLIC_IP}"
}

output "PATROL__VERSION" {
  value = "${var.PATROL_VERSION}"
}

output "PATROL_FS_REST_VERSION" {
  value = "${var.PATROL_FS_REST_VERSION}"
}

output "PATROL_API_VERSION" {
  value = "${var.PATROL_API_VERSION}"
}

output "PATROL_API_STATS_VERSION" {
  value = "${var.PATROL_API_STATS_VERSION}"
}

output "PATROL_ENFORCER_VERSION" {
  value = "${var.PATROL_ENFORCER_VERSION}"
}

output "PATROL_UI_VERSION" {
  value = "${var.PATROL_UI_VERSION}"
}

output "PATROL_EVENT_TRIGGER_VERSION" {
  value = "${var.PATROL_EVENT_TRIGGER_VERSION}"
}

output "PATROL_KUBERNETES_CLUSTER_NAME" {
  value = "${var.patrol_gke_cluster_name}"
}

output "PATROL_CLOUDSQL_PROJECT_ID" {
  value = "${var.patrol_projectid}"
}

output "PATROL_CLOUDSQL_REGION" {
  value = "${var.cloud_sql_instance_region}"
}

output "PATROL_CLOUDSQL_INSTANCE_NAME" {
  value = "${module.create_patrol_cloudsql_instance.name}"
}

output "PATROL_CLOUDSQL_SQL_PORT" {
  value = "${var.PATROL_CLOUDSQL_SQL_PORT}"
}

output "PATROL_CLOUDSQL_GOOGLE_APPLICATION_CREDENTIALS" {
  value = "/keys/${var.cloudsql_service_account_id}.json"
}

output "LOADBALACER_IP_NAME" {
  value = "${var.static_ipaddress_name}"
}

output "LOADBALACER_IP_ADDRESS" {
  value = "${var.static_ipaddress}"
}

output "STATS_FS_API_SERVER" {
  value = "${var.STATS_FS_API_SERVER}"
}

output "STATS_CLOUDSQLPROXY_SERVICE_HOST" {
  value = "${var.PATROL_APISERVER_CLOUDSQLPROXY_SERVICE_HOST}"
}

output "STATS_SQL_PORT" {
  value = "${var.PATROL_CLOUDSQL_SQL_PORT}"
}

output "STATS_FS_API_DB_NAME" {
  value = "${module.create_patrol_apiserver_database.name}"
}

output "STATS_FS_API_DB_USERNAME" {
  value = "${module.create_patrol_apiserver_user.name}"
}

output "STATS_FS_API_DB_PASSWORD" {
  value = "${module.create_patrol_apiserver_user.password}"
}

output "PATROL_STATS_TIME"{
  value = "${var.patrol_stats_time}"
}

output "EVENT_TRIGGER_FS_EVENT_TRIGGER_TOPIC" {
  value = "${var.event_trigger_topic_name}"
}

output "EVENT_TRIGGER_CLIENT_ID" {
  value = "{event_trigger_client_id}"
}

output "EVENT_TRIGGER_IAP_URL" {
  value = "https://${var.patrol_ip_domain}/api/scan"
}

output "EVENT_TRIGGER_FS_EVENT_TRIGGER_SA_EMAIL" {
  value = "${module.create_event_trigger_serviceaccount.email}"
}

output "EVENT_TRIGGER_PATROL_PROJECT_ID" {
  value = "${var.patrol_projectid}"
}

output "EVENT_TRIGGER_FS_OWNER_SA" {
  value = "${var.patrol_project_owner_serviceaccount_key_file_path}"
}

output "SLACK_WEBHOOK_URL" {
  value = "${var.slack_webhook_url}"
}

output "network" {
  value = "${module.create_vpc_network.network}"
}

