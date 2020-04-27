# Patrol Marketplace Application Instructions
## 1. Introduction

Patrol is a cloud security and compliance adherence, monitoring and remediation solution built for Google Cloud Platform (GCP) projects.

Installation of Patrol App in GCP Marketplace needs some assets (listed below) to be pre-created in a Project.
- Service accounts - 5
- Firewall Rules - 1
- Buckets - 2
- Pubsub topics - 3
- Subscription - 3
- 3-Node Kubernetes Cluster -1 [“n1-standard-2”]
- MySQL instance - 1 [2 databases].

Follow the below instructions for installing the above mentioned assets (using an automated script) and also Patrol application in GCP Marketplace.
## 2. Setup an Installer Machine
Follow the below instructions for setting an installer machine, from which script to create GCP assets can be executed.
### 2.1 Installer Machine
A Ubuntu 18.04 machine (bare metal / VM) is needed for executing steps to create required GCP Assets.
### 2.2 Prerequisites
The below packages are needed on the installer machine.
- zip
- wget
- Terraform v0.12.3
- Gcloud v253.0.0 
- git
- curl
- JSON processor (jq)

The pre-requisite packages can be installed  on the installer machine using the script **pre-req-installer.sh**, which is available in the [patrol-k8s-marketplace](https://github.com/Biarca/patrol-k8s-marketplace) repository.

In the installer machine, create a folder (say patrol-installer) and navigate to that folder. If already not installed, install the 'git' package in the installer machine using the below command:
````
$ sudo apt-get install -y git
````
Clone the **"patrol-k8s-marketplace"** repository by using the below command:
````
$ git clone https://github.com/Biarca/patrol-k8s-marketplace.git
````
Then execute the below commands to install the pre-requisite packages.
````
$ cd patrol-k8s-marketplace/
$ sudo bash pre-req-installer.sh
````
# 3. Steps to Install GCP Assets using Script
One GCP project is needed in which all the assets required for installing Biarca Patrol app are created. This project is referred to as Installer project. Though Patrol can monitor the installer project itself, ideally Monitoring Projects are different. The GCP project(s) that needs to be continuously monitored for security misconfigurations are referred to as Monitoring projects.

Follow the below instructions for installing GCP assets on installer project using script.

### 3.1 Creating Service Account
Create a Service account in the installer project and assign the below mentioned roles.
  - 'Owner' role of the Installer Project
  - 'Security Admin' role of the Monitoring Project

**Note:** If the installer project and monitoring project are the same, then just provide Owner role of the installer project to Service account.

In the GCP Console, select Monitoring project and navigate to **IAM & Admin >  Click on "Add"**. Under “New members” provide the Installer project service account and select “Security Admin” as role and click on “Save”.

Download the installer project service account key in JSON format and copy it to the ````<Path-To-patrol-installer>/patrol-k8s-marketplace```` directory in the installer machine. 
### 3.2 Creating External Static Address and DNS Record
For accessing Biarca Patrol UI using an FQDN, perform the below steps in GCP.
#### 3.2.1 Create External Static IP
In GCP console, navigate to Menu -> NETWORKING -> VPC network -> External IP addresses and click on RESERVE STATIC ADDRESSES.
Make sure to provide values as mentioned below and click on the Reserve button.
| **Name** | `<Any user desired name>` |
| :---        |    :----:   |
| **Network Service Tier** | `Premium` |
| **IP Version** | `IPv4` |
| **Type** | `Global` |

**Note:** Make a note of the External Static IP address.
#### 3.2.2 Create a DNS Record for Reserved External Static IP
Create a public domain name (or subdomain) and update its  **'A'** record with reserved static IP. Follow your DNS provider instructions to know more about managing DNS records.
#### 3.2.3 Create Sendgrid API Key
Patrol needs an SMTP server to send email notifications after each scan is performed. For the same Patrol uses SendGrid, which is a cloud-based SMTP provider that allows you to send email without having to maintain email servers.

You can create a free SendGrid API key by creatng an account at https://signup.sendgrid.com/. Once an account is created and basic user inormation is provided, an API key needs to be created. Use the instructions provided here (https://sendgrid.com/docs/ui/account-and-settings/api-keys/#managing-api-keys) to create an API key.

Make a note of the API key.

Note:- As part of the registration process, an email is sent for confirmation. Make sure that you complete the confirmation process.

#### 3.2.4 Create a Slack Webhook URL
If you choose to get notifications on slack also, if already not available, create a slack channel and a webhook URL for the same.  The webhook URL may need to be provided during installation.

### 3.3 Updating Configuration File
In the installer machine, navigate to the terraform folder and in the installer_envs file, update the below list of parameters with user specific info.
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/terraform
````
Below is the list of parameters in **installer_envs** file, which needs to be updated with user specific info, before continuing with the installation.
- **RANDOM_ID**=<#Provide 4 character alphanumeric value. All the resources created as part of installation setup will have this suffix. Example:- 1a1b >
- **PATROL_KEYFILE**=<#Full path of the service account key file created in installer project>
- **PATROL_PROJECTID**=<#GCP project ID of Installer Project>
- **MONITOR_PROJECTID**=<#GCP project ID of Monitoring Project. If the installer project and monitoring project are the same, then provide the installer project ID here>
- **REGION**=<#Region name in which the Installer Project assets (GKE and CloudSQL) will be created. Example:- us-central1>
- **ZONE**=<#Zone name in which the Installer Project assets will be created. Example:- us-central1-c>
- **NETWORK_NAME**=<#Provide a Network which is created with **Automatic** Subnet creation mode. Can be **default** network also>
- **PATROL_DOMAIN_NAME**=<#Domain name reserved (in section 3.2.2) to access Biarca Patrol App>
- **LOADBALACER_IP_NAME**=<#Reserved External Static IP Name (provided in section 3.2.1)>
- **LOADBALACER_IP**=<#Reserved External Static IP (provided in section 3.2.1)>
- **GCP_ORGANIZATION**=<#If the monitoring project is under a GCP organization, provide the domain name of the same. If monitoring project is NOT under any GCP organization, then MANDATORILY provide a value "No organization">
- **SENDGRID_APIKEY**=<#Create a Sendgrid key, which is used to send forseti notifications and provide the key here.
- **FORSETI_EMAIL_SENDER**=<#Email ID for sending Patrol notifications>
- **FORSTI_EMAIL_RECIPIENT**=<#Recipient Email ID for Patrol notifications>
- **GSUITE_SUPER_ADMIN_EMAIL**=<#Email ID of GSUITE SUPER ADMIN>
- **SLACK_WEBHOOK_URL**=<#Slack webhook URL to notify violations and any changes to assets in monitoring projects>
- **SCHEDULER_REGION**=<#Region in which cloud scheduler will be created for scheduling forseti scans>
- **PATROL_STATS_TIME**=<#Frequency in minutes for updating Biarca Patrol statictics in Patrol Dashboard. PLEASE NOTE THAT THE VALUE SHOULD BE ABOVE 15. Example:- 15>

### 3.4 Creating Patrol Specific GCP Resources
Navigate to the path `<Path to patrol-installer>/patrol-k8s-marketplace/terraform` a nd execute the below command to install the required GCP resources in the installer project.
````
$ bash installer.sh
````
As part of the script execution, when prompted for a value provide 'yes'.

**Note:** Post successful completion of the script, few values will be displayed at the end of the script. Those values MUST be provided in the Marketplace UI during the Patrol app installation
### 3.5 Patrol Installation from GCP Marketplace
In the GCP Console, select Installer project and then from the navigation menu click on  Marketplace and search for "Patrol". 
Follow the on-screen instructions and provide the required input values that were used for GCP assets creation as part of section [3.3] to populate the form.
## 4. Post Installation Steps
There are few manual steps which needs to be done post successful installation of Patrol application from marketplace.
### 4.1 Enabling IAP
To control who can access the Biarca Patrol UI, perform the below steps and configure IAP.
In the GCP Console, navigate to Security > Identity-Aware Proxy and Follow the below steps:

    Note:
    1. If Patrol is being installed with organizational account and if IAP is disabled, then Enable it now. Click on CONFIGURE CONSENT SCREEN and select "Internal" option. Click on 'Create' button. Provide an application name (can be anything) and click on 'Save' Button. Navigate back to Identity-Aware Proxy page.
    
    2. If Patrol is being installed with personal GCP account and if IAP is disabled, then Enable it now. Click on CONFIGURE CONSENT SCREEN and select "External" option. Click on Create' button. Provide an application name (can be anything) and click on 'Save' Button. Navigate back to Identity-Aware Proxy page.
- Click on **HTTPS RESOURCES** tab and enable the toggle button beside the entry **patrol-webserver-<RANDOM_ID>** to enable IAP for UI. A pop up appears.
- Select the Checkbox and click on **Turn ON**
- Select the checkbox of the **patrol-webserver-<RANDOM_ID>**. A panel is displayed on the right side.
- Click on the **ADD MEMBER** button.
- In the New members box, provide an **email id** and from the Roles drop down, select **Cloud IAP -> IAP-Secured Web App User**.

**Note:** It takes around 5 minutes for the DNS record and IAP to get updated.
### 4.2 Update Service Accounts
Post successful installation of Biarca Patrol, in the installer project execute the below to remove the Owner role & Security Admin role attached to the service accounts.
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/
$ bash remove_serviceaccount_roles.sh
````

## 5. UnInstalling Patrol
To uninstall the Patrol app from the marketplace, follow the below steps. All the GCP Resources which are created as part of the installation will be removed.

**Note:** Before performing the below, make sure that the installer service account has Project Owner role and monitor service account has Security Admin role.

Execute the below Steps:
1. From **Biarca Patrol UI -> Dashboard**, delete all the project(s).
2. From **Biarca Patrol UI -> Resource Monitoring**, delete all the project(s) which were added post installation.
3. From GCP Console delete “IAP Secrets”. If the installer project is used for multiple projects then it would be difficult to find out the appropriate IAP secret as a unique name will be created for secrets at the time of installation.

   3.a In order to identify the IAP secret for the specific project follow the below steps:
   - Navigate to "**Menu > IAM & Admin > Identity-Aware Proxy**”.
   - Under **HTTPS Resources** right click on the 3 dots  for the web-browser and select **Edit OAuth Client**.
   - Copy the **Name** and **Client ID** of the project.
   - Now Navigate to **Menu > APIs & Services > Credentials**
   - Under the section **OAuth 2.0 Client IDs** click the *check-box* for the project you copied the **Name** and **Client ID**.
   - On the top click on **Delete** option.
4. Delete the sinks created when event-trigger is enabled.
   - Navigate to **Menu > Logging > Logs Router**.
   - Select the sink to be deleted and click on *Delete* on the top.

**Note:** Post-installation if you have deleted the 'patrol-k8s-marketplace' directory in the installer machine, execute the commands from `section [2.2] & section [3.1]` above.

5. Navigate to `<Path to patrol-installer>/patrol-k8s-marketplace/app-data`.
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/app-data/
````
6. If the **'uninstall.envs'** file is not available, then create a new file with name **'uninstall.envs'** and provide the below details and Save it.
    - **PROJECT_ID**=<#Project-ID of the Installer Project>
    - **PATROL_OWNER_SA**=<#Full Path of the Service Account Key file> # Created in section [3.1]
    - **MONITOR_OWNER_SA**=<#Full Path of the Service Account Key file> # Mentioned in Section [3.1]
    - **SCANNER_BUCKET**=<#Patrol Scanner Bucket Name which starts with prefix 'patrol-scanner'>
    - **REGION**=<#GCP Region in which the GCP resources created> # Ex: 'us-central1'
    - **PATROL_KUBERNETES_CLUSTER_NAME**=<#Name of the Kubernetes cluster which starts with prefix'patrol-kube-cluster'>
    - **PATROL_ZONE**=<#Zone in which the GCP resources created> # Ex: 'us-central1-a'

**Note:** If the file 'uninstall.envs' already exists, then make sure all the values in the file are valid.

7. Navigate to the `<Path to patrol-installer>/patrol-k8s-marketplace/terraform/` directory and execute the below command.
````
$ bash uninstall.sh
````
As part of the script execution, when prompted for a value provide 'yes'.

8. Execute section [4.2] to remove the Owner role & Security Admin role attached to the service accounts.

**Note** :- The above script would not delete 'External Static IP' and 'DNS record' which are created in section [3.2] above. These need to be removed manually.


