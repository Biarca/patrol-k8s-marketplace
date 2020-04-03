* `patrol_projectid` id of the project where biarca will be installed

* `patrol_project_owner_serviceaccount_key_file_path` absolute path of the service account key file of project where biarca has to be installed

* `forseti_projectid` id of the project which has to be monitored by biarca
  
* `forseti_project_owner_serviceaccount_key_file_path` absolute path of the service account key file of project which biarca has to monitor
  
* `url_mapper_hosts_list` domain name `["XXX.patrol.biarca.net"]`

* `patrol_ip_domain` domain name example `XXX.patrol.biarca.net`

* `static_ipaddress` ip address of reserved global static ip to which domain is pointing to example `172.16.2.72`
	
* `PATROL_APISERVER_SENDGRID_API_KEY` sendgrid API key

* `PATROL_APISERVER_EMAIL_RECIPIENT` notification email 

* `PATROL_APISERVER_PUBLIC_IP` domain name  with protocol example `https://XXX.patrol.biarca.net`

* `slack_webhook_url` slack webhook url of slack app created for destination slack channel example `https://hooks.slack.com/services/XXX/XXX/XXX`