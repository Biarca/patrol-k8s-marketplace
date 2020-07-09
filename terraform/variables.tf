# Random ID for the setup
variable "random_id"{
  default = "RANDOM_ID"
}

# Id of the project where biarca patrol has to be installed
variable "patrol_projectid" {
  default = "PATROL_PROJECTID"
}

# Owner serviceaccount key file path of the project where biarca patrol has to be installed
variable "patrol_project_owner_serviceaccount_key_file_path" {
  default = "PATROL_KEYFILE"
}

# Default region used in provider for the project where biarca patrol will be installed
variable "patrol_project_default_region" {
  default="REGION"
}

# Id of the project which biarca patrol will be monitoring
variable "fs_projectid" {
  default= "MONITOR_PROJECTID"
}

# Owner serviceaccount key file path of the project which biarca patrol will be monitoring
variable "fs_project_owner_serviceaccount_key_file_path" {
default = "PATROL_KEYFILE"
}

# Default region used in provider for the project where biarca patrol will be monitoring
variable "fs_project_default_region" {
  default="REGION"
}

# Unique id of the enforcer service account
variable enforcer_service_account_id {
  default = "patrol-enforcer-RANDOM_ID"
}

# Name of the enforcer service account
variable enforcer_service_account_name {
  default = "patrol-enforcer-RANDOM_ID"
}

# Unique id of the fs scanner service account
variable fs_service_account_id {
  default = "patrol-fs-RANDOM_ID"
}

# Name of the fs scanner service account
variable fs_service_account_name {
  default = "patrol-fs-RANDOM_ID"
}

# Unique id of the apiserver service account
variable apiserver_service_account_id {
  default = "patrol-apiserver-RANDOM_ID"
}

# Name of the apiserver service account
variable apiserver_service_account_name {
  default = "patrol-apiserver-RANDOM_ID"
}

# Unique id of the cloudsql service account
variable cloudsql_service_account_id {
  default = "patrol-cloudsql-RANDOM_ID"
}

# Name of the cloudsql service account
variable cloudsql_service_account_name {
  default = "patrol-cloudsql-RANDOM_ID"
}

# Event trigger service account name
variable "event_trigger_service_account_name" {
  default = "patrol-eventtrigger-RANDOM_ID"
}

# Name of the event trigger service ID
variable eventtrigger_service_account_id {
  default = "patrol-eventtrigger-RANDOM_ID"
}

# Roles given to enforcer service account for the project which biarca patrol will be monitoring
variable "enforcer_fs_roles" {
    default = ["roles/bigquery.admin","roles/cloudsql.admin","roles/compute.securityAdmin","roles/compute.admin","roles/iam.securityAdmin","roles/storage.admin"]
}

# Roles given to enforcer service account for the project which biarca patrol will be installed
variable "enforcer_patrol_roles"{
  default = ["roles/storage.objectViewer","roles/pubsub.subscriber", "roles/cloudsql.client"]

}

# Roles given to fs scanner for the project which biarca patrol will be monitoring
variable "fs_fs_roles" {
    default = ["roles/appengine.appViewer","roles/bigquery.metadataViewer","roles/browser","roles/cloudasset.viewer","roles/cloudsql.viewer","roles/compute.networkViewer","roles/iam.securityReviewer","roles/orgpolicy.policyViewer","roles/servicemanagement.quotaViewer","roles/serviceusage.serviceUsageConsumer","roles/logging.logWriter","roles/storage.objectViewer"]

}

# Roles given to fs scanner service account for the project  which biarca patrol will be installed
variable "fs_patrol_roles"{
  default = ["roles/storage.objectAdmin","roles/pubsub.subscriber", "roles/iam.serviceAccountTokenCreator"]

}

# Roles given to apiserver service account for the project  which biarca patrol will be installed
variable "apiserver_patrol_roles"{
  default = ["roles/storage.objectAdmin","roles/cloudscheduler.admin","roles/pubsub.admin", "roles/iam.securityReviewer"]
}

# Roles given to apiserver service account for the project  which biarca patrol will be monitoring
variable "apiserver_fs_roles"{
  default = ["roles/logging.configWriter"]
}

# Roles given to cloudsql service account for the project which biarca patrol will be monitoring
variable "cloudsql_patrol_roles" {
  default = ["roles/cloudsql.client"]
}

# Event trigger service account roles
variable "event_trigger_service_account_roles" {
  default = ["roles/pubsub.subscriber"]
}

variable "patrol_vpc_network_name" {
  default = "patrol-network-RANDOM_ID"
}

variable "patrol_vpc_region_name" {
  default = "REGION"
}

variable "patrol_gke_cluster_name" {
  default = "patrol-kube-cluster-RANDOM_ID"
}

variable "patrol_gke_node_pool" {
  default = "default-pool"
}

# Instance type 
variable "patrol_compute_instance_machine_type" {
  default = "n1-standard-2"
}

# Instance zone
variable "patrol_compute_instance_zone" {
  default = "ZONE"
}

# Tags for instance
variable "patrol_compute_instance_tags" {
  default = ["patrol-RANDOM_ID"]
}

# Instance image
variable "patrol_compute_instance_image" {
  default =   "ubuntu-os-cloud/ubuntu-1804-bionic-v20190628"
}

# Instance disk size
variable "patrol_compute_instance_boot_disk_size" {
  default = 80
}

# Instance network
variable "patrol_gke_network" {
  default = "patrol-network-RANDOM_ID"
}

# Instance subnetwork
variable "patrol_gke_subnetwork" {
  default = "patrol-network-RANDOM_ID"
}

# Instance group name
variable "patrol_compute_instance_group_name" {
  default = "patrol-RANDOM_ID"
}

# Instance group description
variable "patrol_compute_instance_group_description" {
  default = "biarca patrol unmanaged instance group"
}


# Instance group ui named port
variable "patrol_compute_instance_group_ui_namedport_name" {
  default = "patrolui-RANDOM_ID"
}

# Instance group ui port number
variable "patrol_compute_instance_group_ui_namedport_port" {
  default = "80"
}

# Instance group zone which must be same as instance zone
variable "patrol_compute_instance_group_zone" {
  default = "ZONE"
}

# Scanner bucket name
variable "patrol_scanner_bucket_name" {
  default = "patrol-scanner-RANDOM_ID"
}

# Cai bucket name
variable "patrol_cai_bucket_name" {
  default = "patrol-cai-RANDOM_ID"
}

# Enforcer pubsub topic name
variable "enforcer_pubsub_topic" {
  default = "patrol-enforcer-RANDOM_ID"
}

# Scanner pubsub topic name
variable "fs_pubsub_topic" {
  default = "patrol-fs-RANDOM_ID"
}


# Enforcer pubsub subscription name
variable "enforcer_pubsub_topic_subscription" {
  default = "patrol-enforcer-sub-RANDOM_ID"
}

# Scanner pubsub subscription name
variable "fs_pubsub_topic_subscription" {
  default = "patrol-fs-sub-RANDOM_ID"
}

# Cloudsql instance name
variable "cloud_sql_instance_name" {
  default = "patrol-sql-RANDOM_ID"
}

# Cloudsql private ip range name
variable "cloudsql_private_ip_name" {
  default = "patrol-cloudsql-ip-RANDOM_ID"
}


# Cloudsql instance region
variable "cloud_sql_instance_region" {
  default = "REGION"
}

# Cloudsql instance type
variable "cloud_sql_instance_tier" {
  default = "db-f1-micro"
}

# Cloudsql instance network
variable "cloud_sql_instance_network" {
  default = "patrol-network-RANDOM_ID"
}


# Apiserver database username
variable "patrol_apiserver_user" {
  default = "patrolapiserver"
}

# Apiserver cloudsql hostname
variable "patrol_apiserver_cloudsql_host" {
  default = "%"
}

# Scanner database username
variable "patrol_fs_user" {
  default = "patrolfs"
}

# Scanner cloudsql hostname
variable "patrol_fs_cloudsql_host" {
  default = "%"
}

# Apiserver database name
variable "patrol_apiserver_cloudsql_database" {
  default = "patrolapiserver"
}

# Scanner database name
variable "patrol_fs_cloudsql_database" {
  default = "patrolfs"
}

# Health check firewall rule name
variable "patrol_allow_health_check_fw_name" {
  default="patrol-allow-RANDOM_ID"
}

# Health check protocol
variable "patrol_allow_health_check_protocol" {
  default = "tcp"
}

# Health check port number
variable "patrol_allow_health_check_ports" {
  default = [80]
}

# Load balancer health check allowed ip ranges
variable "patrol_allow_health_check_source_ranges" {
  default = ["35.191.0.0/16","130.211.0.0/22"]
}

# Health check network
variable "patrol_allow_health_check_network" {
  default="patrol-network-RANDOM_ID"
}



# Health check name
variable "patrol_ui_health_check_name" {
  default = "patrol-ui-RANDOM_ID"
}

# Health check port number
variable "patrol_ui_health_check_port" {
  default = 80
}

# Ui backend service name
variable "ui_backend_service_name"{
  default = "patrol-ui-RANDOM_ID"
}


#url mapper name
variable "url_mapper_name" {
  default = "patrol-mapper-RANDOM_ID"
}

# Url mapper description
variable "url_mapper_description" {
  default = "patrol url mapper"
}

# Url mapper paths block
variable "url_mapper_path_matcher_name" {
  default = "allpaths"
}

# Domain name for url mapper
variable "url_mapper_hosts_list" {
  default = ["PATROL_DOMAIN_NAME"]
}

# Uri mapping route in url mapper
variable "url_mapper_ui_path_list" {
  default = ["/*"]
}

# Ssl certificate name
variable "patrol_ssl_certificate_name"{
  default = "patrol-ssl-RANDOM_ID"
}

# Https proxy name
variable "patrol_https_proxy_name" {
  default = "patrol-proxy-RANDOM_ID"
}

# Forwarding rule name
variable "forwarding_rule_name" {
  default = "patrol-rule-RANDOM_ID"
}

# Loadbalancer Static IP name
variable "static_ipaddress_name" {
  default = "LOADBALACER_IP_NAME"
}

# Loadbalancer Static IP address 
variable "static_ipaddress" {
  default = "LOADBALACER_IP"
}

# Loadbalancer reserved Domain name
variable "patrol_analytics_url" {
  default = "http://PATROL_DOMAIN_NAME/analytics/d/iAjK6IJZk690"
}

# Loadbalancer reserved Domain name
variable "patrol_ip_domain" {
  default = "PATROL_DOMAIN_NAME"
}

# Detailed permissions file path used by enforcer
variable "PATROL_ENFORCER_DETAILED_PERMISSIONS_FILE_PATH" {
  default = "/owlscan-enforcer/fixtures/detailed_permissions_list.json"
}

# Cloudsql host name
variable "PATROL_FS_CLOUDSQLPROXY_SERVICE_HOST" {
  default = "cloudsql"
}

# Organisation name
variable "patrol_fs_gcp_organization" {
  default = "GCP_ORGANIZATION"
}


# Server config path 
variable "PATROL_FS_SERVER_CONF" {
  default = "/fs-security/forseti_conf_server.yaml"
}

# Apiserver container name
variable "PATROL_FS_API_SERVER" {
  default = "patrol-api-server"
}

# Cloudsql host name
variable "PATROL_APISERVER_CLOUDSQLPROXY_SERVICE_HOST" {
  default = "cloudsql"
}

# Sink name
variable "PATROL_APISERVER_SINK_NAME" {
  default = "patrol-sink-RANDOM_ID"
}

# Api server region
variable "patrol_apiserver_region" {
  default = "REGION"
}

# Enable or disable cai
variable "PATROL_APISERVER_CAI_EXPORT_ENABLED" {
  default = "false"
}

# Sendgrid apikey
variable "PATROL_APISERVER_SENDGRID_API_KEY"{
  default = "SENDGRID_APIKEY"
}

# Sender email id
variable "PATROL_APISERVER_EMAIL_SENDER" {
  default = "PATROL_EMAIL_SENDER"
}

# Reciever email id
variable "PATROL_APISERVER_EMAIL_RECIPIENT" {
  default = "PATROL_EMAIL_RECIPIENT"
}

# Apiserver container name
variable "PATROL_FS_REST_SERVER" {
  default = "http://patrol-fs-restserver"
}

# Enforcer container and port on which its serving the api
variable "PATROL_ENFORCER_SERVER" {
  default = "http://patrol-enforcer:8000"
}

# Rules path
variable "PATROL_APISERVER_RULES_PATH" {
  default = "/fs-security/rules"
}

# Domain name 
variable "PATROL_APISERVER_PUBLIC_IP" {
  default = "https://PATROL_DOMAIN_NAME"
}

# Ptrol application version
variable "PATROL_VERSION" {
  default = "2.1.0"
}

# Scanner version
variable "PATROL_FS_REST_VERSION" {
  default = "build-1.0.11"
}

# Apiserver version
variable "PATROL_API_VERSION" {
  default = "build-1.0.44"
}

# Apiserver stats version
variable "PATROL_API_STATS_VERSION" {
  default = "build-1.0.3"
}

# Enforcer version
variable "PATROL_ENFORCER_VERSION" {
  default = "build-1.0.7"
}

# Ui version
variable "PATROL_UI_VERSION" {
  default = "build-1.0.38"
}

# Event trigger version
variable "PATROL_EVENT_TRIGGER_VERSION" {
  default = "build-1.0.12"
}

# Patrol analytics version
variable "PATROL_ANALYTICS_VERSION" {
  default = "build-1.0.15"
}

# Cloudsql port number
variable "PATROL_CLOUDSQL_SQL_PORT" {
  default = "3306"
}

# Docker envs path
variable "docker_env_files_path" {
  default = "../app-data/docker.envs"
}

# Kubernetes envs path
variable "kube_env_files_path" {
  default = "../app-data/kube-deployment.envs"
}


# Scanner envs path
variable "docker_fs_env_files_path" {
  default = "../app-data/fs.envs"
}

# Enforcer envs path
variable "docker_enforcer_env_files_path" {
  default = "../app-data/enforcer.envs"
}

# Apiserver envs path
variable "docker_apiserver_env_files_path" {
  default = "../app-data/apiserver.envs"
}

# Cloudsql envs path
variable "docker_cloudsql_env_files_path" {
  default = "../app-data/cloudsql.envs"
}

# Cloudsql cred envs path
variable "docker_cloudsql_cred_env_files_path" {
  default = "../app-data/cloudsql-cred.envs"
}

# Event_trigger envs path
variable "docker_eventtrigger_env_files_path" {
  default = "../app-data/eventtrigger.envs"
}

# patrol_analytics envs path
variable "docker_patrol_analytics_env_files_path" {
  default = "../app-data/patrol-analytics.envs"
}

# Unstall envs path
variable "uninstall_env_files_path" {
  default = "../app-data/uninstall.envs"
}

# Apiserver container name
variable "STATS_FS_API_SERVER" {
  default = "http://patrol-api-server:8000"
}

# Stats refresh interval
variable "patrol_stats_time" {
  default = "PATROL_STATS_TIME"
}

# Stats env file path
variable "docker_stats_env_files_path" {
  default = "../app-data/stats.envs"
}

# Event trigger pubsub topic name
variable "event_trigger_topic_name" {
  default = "patrol-eventtrigger-RANDOM_ID"
}


# Event trigger pubsub subscription name
variable "event_trigger_subscription_name" {
  default = "patrol-eventtriggger-sub-RANDOM_ID"
}


# Force destroy buckets even if objects are present in it
variable "force_destroy_buckets" {
  default = true
}

# Slack webhook url
variable "slack_webhook_url"{
  default = "SLACK_WEBHOOK_URL"
}

variable "patrol_appengine_location_id" {
  default = "SCHEDULER_REGION"
}

# Path where the creted serviceaccounts key files will be saved
variable "patrol_keys_path" {
  default = "../app-data/keys"
}
