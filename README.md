# Patrol Marketplace Application Instructions
## 1. Introduction

Patrol is a cloud security and compliance adherence, monitoring and remediation solution built for Google Cloud Platform (GCP) Projects.

Prior to the installation of Patrol App in GCP Marketplace, the following assets to be created in a Project.
- Service accounts - 5
- Firewall Rules - 1
- Buckets - 2
- Pubsub topics - 3
- Subscription - 3
- 3-Node Kubernetes Cluster -1 [“n1-standard-2”]
- MySQL instance - 1 [2 databases]
- App Engine - 1

### 1.1 Installer Machine
An Ubuntu 18.04 machine (VM / Bare Metal / GCE) is needed to create the above mentioned assets using an automated script. This machine will be referred to as an Installer machine.
### 1.2 Installer Project
A new GCP project is needed in which all the assets required for installing Patrol app are created. This project is referred to as an Installer Project. 
### 1.3 Monitoring Project
Though Patrol can monitor the installer project itself, ideally Monitoring Projects are different. The GCP project(s) that need to be continuously monitored for security misconfigurations are referred to as Monitoring Project.
## 2. Configuring an Installer Machine
Follow the instructions below for setting up an installer machine to execute scripts that create GCP assets.
### 2.1 Prerequisites
The below packages are needed on the installer machine.
- zip
- wget
- Terraform v0.12.26
- Gcloud v253.0.0 and above
- curl
- git
- JSON processor (jq)

**Note**: If already not installed, the above mentioned packages will be installed by the installation script (executed in section #3.5 below).
### 2.2 Clone the Git Repository
In the installer machine, create a folder (e.g. patrol-installer) and navigate to that folder. If already not installed, install the 'git' package using the below command:
````
$ sudo apt-get install -y git
````
Clone the **"patrol-k8s-marketplace"** repository by using the below command:
````
$ git clone https://github.com/Biarca/patrol-k8s-marketplace.git
````
# 3. Steps to Install GCP Assets using Script
Perform the following instructions to install GCP assets on the Installer Project using script.
### 3.1 Creating Service Account
Create a Service account in the Installer Project and assign the below mentioned roles.
  - 'Owner' role of the Installer Project
  - 'Security Admin' role of the Monitoring Project

**Note:** If the Installer Project and Monitoring Project are the same, then provide Owner role of the Installer Project to the Service account.

In the GCP Console, select Monitoring Project and navigate to **IAM & Admin > IAM** and Click on "Add". Under “New members” provide the Installer Project service account and select “Security Admin” as the role and click on “Save”.
In the Installer Project, navigate to **IAM & Admin > Service Accounts**, for the desired service account, click on the 3-dots under the Actions column and click on "Create Key". Select the key type as "JSON" and click on "CREATE".

Download the Installer Project service account key in JSON format and copy it to the ````<Path-To-patrol-installer>/patrol-k8s-marketplace/terraform```` directory in the installer machine. 
### 3.2 Creating External Static Address and DNS Record
To access Biarca Patrol UI using an FQDN, perform the following instructions in GCP.
#### 3.2.1 Create External Static IP
In the Installer Project, navigate to **Menu -> NETWORKING -> VPC network -> External IP addresses** and click on **"RESERVE STATIC ADDRESSES"**.
Make sure to provide values as mentioned below and click on the **"Reserve"** button.
| **Name** | `<Any user desired name>` |
| :---        |    :----:   |
| **Network Service Tier** | `Premium` |
| **IP Version** | `IPv4` |
| **Type** | `Global` |

**Note:** Record both External Static IP Name and IP address.
#### 3.2.2 Create a DNS Record for Reserved External Static IP
Create a public domain name (or subdomain) and update its  **'A'** record with reserved static IP. Follow your DNS provider instructions to know more about managing DNS records.
#### 3.2.3 Create Sendgrid API Key
Patrol requires an SMTP server to send email notifications after each scan is performed. To achieve this, Patrol uses SendGrid (a cloud-based SMTP provider) which enables transmission of emails, without having to maintain email servers.

You can create a free SendGrid API key by creating an account at [Send Grid](https://signup.sendgrid.com/). Once an account is created and basic user information is provided, an API key needs to be created. To create an API key, follow the instructions below:

- Navigate to **"Settings"** on the left navigation bar, and then select **"API Keys"**.
- Click **"Create API Key"**
- Give your API key a name
- Select **"Full Access"**
- Click **Create & View**
- Record your API key. **Please note that this key is displayed only once**

Note: As part of the registration process, a confirmation email will be sent. Make sure that you complete the confirmation process.

#### 3.2.4 Create a Slack Webhook URL
To receive notifications on Slack also, if not already available, create a Slack channel and a Webhook URL. The Webhook URL may need to be provided during installation. 

Follow these intructions to create a Webhook URL:
- Create a channel in one of your Slack workspaces.
- Go to the [Slack app page](https://api.slack.com/apps).
- Click on **"Create New App"**. Enter the name for the App and Workspace to deploy it.
- Click on **"Incoming Webhooks"** under **Features** of created App and enable **"Activate Incoming Webhooks"**.
- Click on **"Add New Webhook to Workspace"** and enter the **Channel Name** you want to post the notifications from Patrol and click on the **"Authorize"** button.
- In the **Incoming Webhooks** page of the created App, scroll down and copy the "**Webhook URL**".

### 3.3 Updating Configuration File
In the installer machine, navigate to the terraform folder and in the installer_envs file, update the list of parameters below with user specific info:
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/terraform
````
Below is the list of parameters in the **installer_envs** file which needs to be updated with user specific info before continuing with the installation.
- **RANDOM_ID**=<#Provide 4 character alphanumeric value. All the resources created as part of the installation setup will have this suffix. Example: 1a1b >
- **PATROL_KEYFILE**=<#Full path of the service account key file created in Installer Project>
- **PATROL_PROJECTID**=<#GCP project ID of Installer Project>
- **MONITOR_PROJECTID**=<#GCP project ID of Monitoring Project. If the Installer Project and Monitoring Project are the same, then provide the Installer Project ID here>
- **REGION**=<#Region name on which the assets(GKE and CloudSQL) will be created>
- **ZONE**=<#Zone name on which the assets will be created>
- **PATROL_DOMAIN_NAME**=<#Domain name reserved (in section 3.2.2) to access Biarca Patrol App>
- **LOADBALACER_IP_NAME**=<#Reserved External Static IP Name (provided in section 3.2.1)>
- **LOADBALACER_IP**=<#Reserved External Static IP (provided in section 3.2.1)>
- **GCP_ORGANIZATION**=<#If the monitoring project is under a GCP organization, provide the domain name of the same. If monitoring project is NOT under a GCP organization, then MANDATORILY provide a value "No organization">
- **SENDGRID_APIKEY**=<#Create a Sendgrid key, which is used to send patrol notifications and provide the key here>
- **PATROL_EMAIL_SENDER**=<#Email ID for sending Patrol notifications>
- **PATROL_EMAIL_RECIPIENT**=<#Recipient Email ID for Patrol notifications>
- **SLACK_WEBHOOK_URL**=<#Slack webhook URL to notify violations and any changes to assets in monitoring projects. This is an **optional** parameter. Comment (using '#') this parameter to ignore>
- **SCHEDULER_REGION**=<#Region on which cloud scheduler will be created for scheduling patrol scans>
- **PATROL_STATS_TIME**=<#Frequency in minutes for updating Biarca Patrol statistics in Patrol Dashboard. PLEASE NOTE THAT THE VALUE SHOULD BE ABOVE 15. Example: 15>

### 3.4 Creating Patrol Specific GCP Resources
Navigate to the path `<Path to patrol-installer>/patrol-k8s-marketplace/terraform` and execute the below command to install the required GCP resources in the installer project.
````
$ bash patrol-pre-requisites.sh
````
As part of the script execution, it will prompt for the user's password to run a few sudo commands. Also when it prompts for a value provide 'yes'.

**Note:** Post successful completion of the script, record the values displayed at the end of the script. Those values MUST be provided in the Marketplace UI during the Patrol app installation
### 3.5 Patrol Installation from GCP Marketplace
Go to [GCP Console](https://console.cloud.google.com/marketplace/details/patrol-public/patrol), select Installer project and click on the "Configure" button. 
Follow the on-screen instructions and provide the required input values that were used for GCP assets creation as part of section [3.3] to populate the form. Click on the **"Deploy"** button.
## 4. Post Installation Steps
There are a few manual steps which need to be done post successful installation of Patrol application from marketplace.
### 4.1 Enabling IAP
To control who can access the Biarca Patrol UI, perform the below steps and configure IAP.
In the GCP Console, navigate to Security > Identity-Aware Proxy and Follow the below steps:

    Note:
    1. If Patrol is being installed with an organizational account and if IAP is disabled, then enable it now. Click on CONFIGURE CONSENT SCREEN and select "Internal" option. Click on the 'Create' button. Provide an application name (can be anything) and click on the 'Save' Button. Navigate back to the Identity-Aware Proxy page.
    
    2. If Patrol is being installed with a personal GCP account and if IAP is disabled, then enable it now. Click on CONFIGURE CONSENT SCREEN and select "External" option. Click on the ' Create' button. Provide an application name (can be anything) and click on the 'Save' Button.
- Navigate back to the Identity-Aware Proxy page.
- Click on **HTTPS RESOURCES** tab and enable the toggle button beside the entry **patrol-webserver-<RANDOM_ID>** to enable IAP for UI. A pop up appears.
- Select the Checkbox and click on **Turn ON**
- Select the checkbox of the **patrol-webserver-<RANDOM_ID>**. A panel is displayed on the right side.
- Click on the **ADD MEMBER** button.
- In the New members box, provide an **email id** and from the Roles drop down, select **Cloud IAP -> IAP-Secured Web App User**.
**Note:** It takes around 5 minutes for the DNS record and IAP to get updated. Also you can ignore the "**kube-system/default-http-backend**" service.

### 4.2 Update Service Accounts
Post successful installation of Biarca Patrol, in the installer project execute the below to remove the Owner role & Security Admin role attached to the service accounts.
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/
$ bash remove_serviceaccount_roles.sh
````

## 5. UnInstalling Patrol
To uninstall the Patrol app from the marketplace, follow the steps below. All the GCP Resources which are created as part of the installation will be removed.

**Note:** Before performing the below, make sure that the installer service account has 'Project Owner' role of the installer project and 'Security Admin' role of the monitoring project.

Execute the below Steps:
1. From **Biarca Patrol UI -> Dashboard**, delete all the project(s).
2. From **Biarca Patrol UI -> Manage Projects**, delete all the project(s) which were added post installation.
3. From GCP Console delete “IAP Secrets”. If the installer project is used for multiple projects then it would be difficult to find out the appropriate IAP secret, as a unique name will be created for secrets at the time of installation.

   3.a In order to identify the IAP secret for the specific project follow the below steps:
   - Navigate to "**Menu > IAM & Admin > Identity-Aware Proxy**”.
   - Under **HTTPS Resources** right click on the 3 dots  for the web-browser and select **Edit OAuth Client**.
   - Copy the **Name** and **Client ID** of the project.
   - Now Navigate to **Menu > APIs & Services > Credentials**
   - Under the section **OAuth 2.0 Client IDs** click the *check-box* for the project you copied the **Name** and **Client ID**.
   - On the top click on the **Delete** option.
4. Delete the sinks created when the event-trigger is enabled.
   - Navigate to **Menu > Logging > Logs Router**.
   - Select the sink to be deleted and click on *Delete* on the top.

**Note:** Post-installation if you have deleted the 'patrol-k8s-marketplace' directory in the installer machine, execute the commands from `section [2.2] & section [3.1]` above.

5. Navigate to `<Path to patrol-installer>/patrol-k8s-marketplace/app-data`.
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/app-data/
````
6. If the **'uninstall.envs'** file is not available, then create a new file with name **'uninstall.envs'**, provide the details below, then Save it.
    - **PROJECT_ID**=<#Project-ID of the Installer Project>
    - **PATROL_OWNER_SA**=<#Full Path of the Service Account Key file> # Created in section [3.1]
    - **MONITOR_OWNER_SA**=<#Full Path of the Service Account Key file> # Mentioned in Section [3.1]
    - **SCANNER_BUCKET**=<#Patrol Scanner Bucket Name which starts with prefix 'patrol-scanner'>
    - **REGION**=<#GCP Region in which the GCP resources created> # Ex: 'us-central1'
    - **PATROL_KUBERNETES_CLUSTER_NAME**=<#Name of the Kubernetes cluster which starts with prefix'patrol-kube-cluster'>
    - **PATROL_ZONE**=<#Zone in which the GCP resources created> # Ex: 'us-central1-a'
    - **PATROL_NETWORK**=<#Patrol Network in which the GCP Assets Created> # Ex: 'patrol-network-<RANDOM_ID>'

**Note:** If the file 'uninstall.envs' already exists, then make sure all the values in the file are valid.

7. Navigate to the `<Path to patrol-installer>/patrol-k8s-marketplace/terraform/` directory and execute the below command.
````
$ bash uninstall.sh
````
As part of the script execution, when prompted for a value respond with 'yes'.

8. Execute section [4.2] to remove the Owner role & Security Admin role attached to the service accounts.

**Note** : The above script would not delete 'External Static IP' and 'DNS record' which are created in section [3.2] above. These will need to be removed manually.

