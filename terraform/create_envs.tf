
resource "null_resource" "create_kube_envs" {
    triggers = {
      data="${timestamp()}"
    }

  provisioner "local-exec" {
    command = <<EOT
      truncate -s 0 ${var.kube_env_files_path}
      echo RANDOM_ID=${var.random_id} >> ${var.kube_env_files_path}
      echo PATROL_OWNER_SA=${var.patrol_project_owner_serviceaccount_key_file_path} >> ${var.kube_env_files_path}
      echo PATROL_KUBERNETES_CLUSTER_NAME=${var.patrol_gke_cluster_name} >> ${var.kube_env_files_path}
      echo KUBERNETES_CLUSTER_NODEPOOL=${var.patrol_gke_node_pool} >> ${var.kube_env_files_path}
      echo PROJECT_ID=${var.patrol_projectid}  >> ${var.kube_env_files_path}
      echo PATROL_ZONE=${var.patrol_compute_instance_zone} >> ${var.kube_env_files_path}
      echo STATIC_IP_NAME=${var.static_ipaddress_name} >> ${var.kube_env_files_path}
      echo PATROL_SSL_CERTIFICATE_NAME=${var.patrol_ssl_certificate_name} >> ${var.kube_env_files_path}
      echo PATROL_DOMAIN_NAME=${var.patrol_ip_domain} >> ${var.kube_env_files_path}
      echo SCANNER_BUCKET=${module.create_patrol_scanner_bucket.name} >> ${var.kube_env_files_path}
      echo ROOT_RESOURCE_ID=projects/${var.fs_projectid} >> ${var.kube_env_files_path}
      
      echo PATROL_API_SERVER_TAG=${var.PATROL_API_VERSION} >> ${var.kube_env_files_path}
      echo PATROL_ENFORCER_SERVER_TAG=${var.PATROL_ENFORCER_VERSION} >> ${var.kube_env_files_path}
      echo PATROL_WEB_SERVER_TAG=${var.PATROL_UI_VERSION} >> ${var.kube_env_files_path}
      echo PATROL_FS_SERVER_TAG=${var.PATROL_FS_REST_VERSION} >> ${var.kube_env_files_path}
      echo PATROL_API_STATS_SERVER_TAG=${var.PATROL_API_STATS_VERSION} >> ${var.kube_env_files_path}
      echo PATROL_EVENT_TRIGGER_TAG=${var.PATROL_EVENT_TRIGGER_VERSION} >> ${var.kube_env_files_path}

      echo CLOUDSQL_CREDENTIALS=./keys/${var.cloudsql_service_account_id}.json >> ${var.kube_env_files_path}
      echo PATROL_API_CREDENTIALS=./keys/${var.apiserver_service_account_id}.json >> ${var.kube_env_files_path}
      echo PATROL_FS_CREDENTIALS=./keys/${var.fs_service_account_id}.json >> ${var.kube_env_files_path}
      echo PATROL_ENFORCER_CREDENTIALS=./keys/${var.enforcer_service_account_id}.json >> ${var.kube_env_files_path}
      echo PATROL_EVENTTRIGGER_CREDENTIALS=./keys/${var.eventtrigger_service_account_id}.json >> ${var.kube_env_files_path}


      echo CLOUDSQL_DB_NAME=${module.create_patrol_apiserver_database.name} >> ${var.kube_env_files_path}
      echo CLOUDSQL_DB_USERNAME=${module.create_patrol_apiserver_user.name} >> ${var.kube_env_files_path}
      echo CLOUDSQL_DB_PASSWORD=${module.create_patrol_apiserver_user.password} >> ${var.kube_env_files_path}
      echo SQL_PORT="${var.PATROL_CLOUDSQL_SQL_PORT}"  >> ${var.kube_env_files_path}
      echo PATROL_ANALYTICS_VERSION="${var.PATROL_ANALYTICS_VERSION}"  >> ${var.kube_env_files_path}
      
    EOT
  }
}

resource "null_resource" "create_enforcer_envs" {
    triggers = {
      data="${timestamp()}"
    }

  provisioner "local-exec" {
    command = <<EOT
      truncate -s 0 ${var.docker_enforcer_env_files_path}
      echo GOOGLE_APPLICATION_CREDENTIALS=/keys/${var.enforcer_service_account_id}.json >> ${var.docker_enforcer_env_files_path}
      echo DETAILED_PERMISSIONS_FILE_PATH=${var.PATROL_ENFORCER_DETAILED_PERMISSIONS_FILE_PATH} >> ${var.docker_enforcer_env_files_path}
      echo SCANNER_BUCKET=${module.create_patrol_scanner_bucket.name} >> ${var.docker_enforcer_env_files_path}
      echo ENFORCER_PROJECT=${var.patrol_projectid} >> ${var.docker_enforcer_env_files_path}
      echo ENFORCER_SUBSCRIPTION_NAME=${module.create_patrol_enforcer_subscription.name} >> ${var.docker_enforcer_env_files_path}
      echo FS_API_SERVER=${var.PATROL_FS_API_SERVER} >> ${var.docker_enforcer_env_files_path}
    EOT
  }
}

resource "null_resource" "create_fs_envs" {
    triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
      truncate -s 0 ${var.docker_fs_env_files_path}
      echo GOOGLE_APPLICATION_CREDENTIALS=/keys/${var.fs_service_account_id}.json >> ${var.docker_fs_env_files_path}
      echo BUCKET=gs://${module.create_patrol_scanner_bucket.name}  >> ${var.docker_fs_env_files_path}
      echo GCP_ORGANIZATION=${var.patrol_fs_gcp_organization} >> ${var.docker_fs_env_files_path}
      echo PROJECT_ID=${var.patrol_projectid}  >> ${var.docker_fs_env_files_path}
      echo SUBSCRIPTION_NAME=${module.create_patrol_fs_subscription.name}  >> ${var.docker_fs_env_files_path}
      echo FS_SERVER_CONF=${var.PATROL_FS_SERVER_CONF}  >> ${var.docker_fs_env_files_path}
      echo FS_API_SERVER=${var.PATROL_FS_API_SERVER}  >> ${var.docker_fs_env_files_path}
    EOT
  }
}

resource "null_resource" "create_apiserver_envs" {
    triggers = {
      data="${timestamp()}"
    }
    provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.docker_apiserver_env_files_path}
    echo SCANNER_TOPIC_NAME=${module.create_patrol_fs_pubsub_topic.name} >> ${var.docker_apiserver_env_files_path}
    echo ENFORCER_TOPIC_NAME=${module.create_patrol_enforcer_pubsub_topic.name} >> ${var.docker_apiserver_env_files_path}
    echo GOOGLE_APPLICATION_CREDENTIALS=/keys/${var.apiserver_service_account_id}.json >> ${var.docker_apiserver_env_files_path}
    echo API_BUCKET=${module.create_patrol_scanner_bucket.name} >> ${var.docker_apiserver_env_files_path}
    echo CAI_BUCKET=${module.create_patrol_cai_bucket.name} >> ${var.docker_apiserver_env_files_path}
    echo SINK_NAME=${var.PATROL_APISERVER_SINK_NAME} >> ${var.docker_apiserver_env_files_path}
    echo PROJECT_ID=${var.patrol_projectid} >> ${var.docker_apiserver_env_files_path}
    echo FS_SERVER_CONF=${var.PATROL_FS_SERVER_CONF} >> ${var.docker_apiserver_env_files_path}
    echo EVENT_TRIGGER_TOPIC_NAME=${var.event_trigger_topic_name} >> ${var.docker_apiserver_env_files_path}
    echo REGION=${var.patrol_apiserver_region} >> ${var.docker_apiserver_env_files_path}
    echo CAI_EXPORT_ENABLED=${var.PATROL_APISERVER_CAI_EXPORT_ENABLED} >> ${var.docker_apiserver_env_files_path}
    echo SENDGRID_API_KEY=${var.PATROL_APISERVER_SENDGRID_API_KEY} >> ${var.docker_apiserver_env_files_path}
    echo EMAIL_SENDER=${var.PATROL_APISERVER_EMAIL_SENDER} >> ${var.docker_apiserver_env_files_path}
    echo EMAIL_RECIPIENT=${var.PATROL_APISERVER_EMAIL_RECIPIENT} >> ${var.docker_apiserver_env_files_path}
    echo FS_REST_SERVER=${var.PATROL_FS_REST_SERVER} >> ${var.docker_apiserver_env_files_path}
    echo FS_ENFORCER_SERVER=${var.PATROL_ENFORCER_SERVER} >> ${var.docker_apiserver_env_files_path}
    echo RULES_PATH=${var.PATROL_APISERVER_RULES_PATH} >> ${var.docker_apiserver_env_files_path}
    echo PUBLIC_IP=${var.PATROL_APISERVER_PUBLIC_IP} >> ${var.docker_apiserver_env_files_path}
    echo PATROL_VERSION=${var.PATROL_VERSION} >> ${var.docker_apiserver_env_files_path}
    echo SLACK_WEBHOOK_URL="${var.slack_webhook_url}">>${var.docker_apiserver_env_files_path}
    echo APISERVER_SA=${module.create_apiserver_service_account.email} >> ${var.docker_apiserver_env_files_path}
    echo FS_SA=${module.create_fs_service_account.email} >> ${var.docker_apiserver_env_files_path}
    echo ENFORCER_SA=${module.create_enforcer_service_account.email} >> ${var.docker_apiserver_env_files_path}
    echo ANALYTICS_URL=${var.patrol_analytics_url} >> ${var.docker_apiserver_env_files_path}
    echo SCHEDULER_REGION=${var.patrol_appengine_location_id} >> ${var.docker_apiserver_env_files_path}

    EOT
  }
}

resource "null_resource" "create_cloudsql_envs" {
    triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.docker_cloudsql_env_files_path}
    echo PROJECT_ID=${var.patrol_projectid} >> ${var.docker_cloudsql_env_files_path}
    echo REGION=${var.cloud_sql_instance_region} >> ${var.docker_cloudsql_env_files_path}
    echo INSTANCE_NAME=${module.create_patrol_cloudsql_instance.name} >> ${var.docker_cloudsql_env_files_path}
    echo SQL_PORT=${var.PATROL_CLOUDSQL_SQL_PORT} >> ${var.docker_cloudsql_env_files_path}
    echo GOOGLE_APPLICATION_CREDENTIALS=/keys/${var.cloudsql_service_account_id}.json >> ${var.docker_cloudsql_env_files_path}
    EOT
  }
}

resource "null_resource" "create_cloudsql_cred_envs" {
    triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.docker_cloudsql_cred_env_files_path}
    echo FS_API_DB_NAME=${module.create_patrol_apiserver_database.name} >> ${var.docker_cloudsql_cred_env_files_path}
    echo FS_API_DB_USERNAME=${module.create_patrol_apiserver_user.name} >> ${var.docker_cloudsql_cred_env_files_path}
    echo FS_API_DB_PASSWORD=${module.create_patrol_apiserver_user.password} >> ${var.docker_cloudsql_cred_env_files_path}
    echo FS_DB_NAME=${module.create_patrol_fs_database.name}  >> ${var.docker_cloudsql_cred_env_files_path}
    echo FS_DB_USERNAME=${module.create_patrol_fs_user.name}  >> ${var.docker_cloudsql_cred_env_files_path}
    echo FS_DB_PASSWORD=${module.create_patrol_fs_user.password} >> ${var.docker_cloudsql_cred_env_files_path}
    EOT
  }
}

resource "null_resource" "create_event_trigger_envs" {
      triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.docker_eventtrigger_env_files_path}
    echo GOOGLE_APPLICATION_CREDENTIALS=/keys/${var.eventtrigger_service_account_id}.json >> ${var.docker_eventtrigger_env_files_path}
    echo FS_API_SERVER=${var.PATROL_FS_API_SERVER}  >> ${var.docker_eventtrigger_env_files_path}
    echo FS_EVENT_TRIGGER_TOPIC="${var.event_trigger_topic_name}" >> ${var.docker_eventtrigger_env_files_path}
    echo FS_EVENT_TRIGGER_SUBSCRIPTION="${var.event_trigger_subscription_name}" >> ${var.docker_eventtrigger_env_files_path}
    echo DOMAIN_NAME="${var.patrol_ip_domain}">>${var.docker_eventtrigger_env_files_path}
    echo PATROL_PROJECT_ID="${var.patrol_projectid}">>${var.docker_eventtrigger_env_files_path}
    echo SLACK_WEBHOOK_URL="${var.slack_webhook_url}">>${var.docker_eventtrigger_env_files_path}
    echo ENFORCER_SA=${module.create_enforcer_service_account.email} >> ${var.docker_eventtrigger_env_files_path}
    EOT
  }
}


resource "null_resource" "create_stats_envs" {
      triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.docker_stats_env_files_path}
    echo FS_API_SERVER=${var.STATS_FS_API_SERVER} >> ${var.docker_stats_env_files_path}
    echo CLOUDSQLPROXY_SERVICE_HOST="${var.PATROL_APISERVER_CLOUDSQLPROXY_SERVICE_HOST}" >> ${var.docker_stats_env_files_path}
    echo SQL_PORT="${var.PATROL_CLOUDSQL_SQL_PORT}"  >> ${var.docker_stats_env_files_path}
    echo FS_API_DB_NAME="${module.create_patrol_apiserver_database.name}" >> ${var.docker_stats_env_files_path}
    echo FS_API_DB_USERNAME="${module.create_patrol_apiserver_user.name}" >> ${var.docker_stats_env_files_path}
    echo FS_API_DB_PASSWORD="${module.create_patrol_apiserver_user.password}" >> ${var.docker_stats_env_files_path}
    echo STATS_TIME="${var.patrol_stats_time}" >> ${var.docker_stats_env_files_path}
    EOT
  }
}


resource "null_resource" "uninstall_envs" {
      triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.uninstall_env_files_path}
    echo PROJECT_ID=${var.patrol_projectid}  >> ${var.uninstall_env_files_path}
    echo PATROL_OWNER_SA=${var.patrol_project_owner_serviceaccount_key_file_path}  >> ${var.uninstall_env_files_path}
    echo MONITOR_OWNER_SA=${var.fs_project_owner_serviceaccount_key_file_path} >> ${var.uninstall_env_files_path}
    echo SCANNER_BUCKET=${module.create_patrol_scanner_bucket.name} >> ${var.uninstall_env_files_path}
    echo REGION=${var.patrol_project_default_region}  >> ${var.uninstall_env_files_path}
    echo PATROL_KUBERNETES_CLUSTER_NAME=${var.patrol_gke_cluster_name} >> ${var.uninstall_env_files_path}
    echo PATROL_ZONE=${var.patrol_compute_instance_zone} >> ${var.uninstall_env_files_path}
    echo PATROL_NETWORK=${var.patrol_vpc_network_name} >> ${var.uninstall_env_files_path}
    EOT
  }
}

resource "null_resource" "create_patrol_analytics_envs" {
      triggers = {
      data="${timestamp()}"
    }
  provisioner "local-exec" {
    command = <<EOT
    truncate -s 0 ${var.docker_patrol_analytics_env_files_path}
    echo GF_SERVER_DOMAIN=${var.patrol_ip_domain} >> ${var.docker_patrol_analytics_env_files_path}
    echo GF_SERVER_ROOT_URL="%(protocol)s://%(domain)s/analytics" >> ${var.docker_patrol_analytics_env_files_path}
    echo GF_SERVER_FROM_SUB_PATH=true >> ${var.docker_patrol_analytics_env_files_path}
    echo GF_USERS_DEFAULT_THEME=light >> ${var.docker_patrol_analytics_env_files_path}
    echo GF_AUTH_DISABLE_LOGIN_FORM=true >> ${var.docker_patrol_analytics_env_files_path}
    echo GF_AUTH_ANONYMOUS_ENABLED=true >> ${var.docker_patrol_analytics_env_files_path}
    echo GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer >> ${var.docker_patrol_analytics_env_files_path}
    EOT
  }
}
