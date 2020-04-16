# Patrol Marketplace Application Instructions
## 1. Introduction

Patrol is a cloud security and compliance adherence, monitoring and remediation solution built for Google Cloud Platform (GCP) projects.

Installation of Patrol in GCP Marketplace needs some assets (listed below) to be pre-created in a Project.
- Service accounts - 5
- Firewall Rules - 1
- Buckets - 2
- Pubsub topics - 3
- Subscription - 3
- 3-Node Kubernetes Cluster -1 [“n1-standard-2”]
- MySQL instance - 1 [2 databases].

Follow the below instructions for installing the above mentioned assets (using an automated script) and also Patrol application in GCP Marketplace.
## 2. Steps to Install GCP Assets using Script
Follow the below instructions for installing GCP assets using script.
### 2.1 Installer Machine
A Ubuntu 18.04 machine (bare metal / VM) is needed for executing steps to create required GCP Assets.
### 2.2 Prerequisites
The below packages are needed on the installer machine.
- zip
- wget
- Terraform v0.12.3
- Gcloud v253.0.0 
- git
- JSON processor (jq)

The pre-requisite packages can be installed  on the installer machine using the script **pre-req-installer.sh**, which is available in the patrol-k8s-marketplace repository.

The first task would be to clone the repository **"patrol-k8s-marketplace"**.
Clone the git repository by using the below commands:
````
$ git clone https://github.com/Biarca/patrol-k8s-marketplace.git
````
Then execute the below commands to install the pre-requisite packages.
````
$ cd patrol-k8s-marketplace
$ sudo bash pre-req-installer.sh
````

# 3. Installation Procedure
In the installer machine, create a folder (say Patrol-installer) and navigate to that folder.
`Note: Assumption is the Patrol installer project & Monitoring project are different.`
### 3.1 Creating Service Account
Create a Service account in the installer project and assign the below mentioned roles.
  - **Installer Project** - Add Project Owner role for Installer Project service account
  - **Monitoring Project** - Add Security Admin role for Installer Project service account
**Note:** If the installer project and monitoring project are same, then provide Owner role of the project to Service acccount.

In the GCP Console, navigate to **IAM & Admin >  Click on "Add"**. Under “New members” give the Installer project service account and select “Security Admin” as role and click on “Save”.

Download the key in JSON format and copy them to the ````<Path-To-Patrol-installer>/patrol-k8s-marketplace```` directory in the installer machine. 
### 3.2 Creating External Static Address and DNS Record
For accessing Biarca Patrol UI using an FQDN, perform the below steps in GCP.
#### 3.2.1 Create External Static IP
In GCP console, navigate to <Installer Project> -> NETWORKING -> VPC network -> External IP addresses and click on RESERVE STATIC ADDRESSES.
Make sure to provide values as mentioned below and click on the Reserve button.
| **Name** | `<Any user desired name>` |
| :---        |    :----:   |
| **Network Service Tier** | `Premium` |
| **IP Version** | `IPv4` |
| **Type** | `Global` |

**Note:** Make a note of the External Static IP address.
#### 3.2.2 Create a DNS Record for Reserved External Static IP
Create a public domain name (or subdomain) and update its  **'A'** record with reserved static IP. Follow your DNS provider instructions to know more about managing DNS records.
### 3.3 Updating Configuration File
Navigate to the terraform folder.
````
$ cd <Path to Patrol-installer>/patrol-k8s-marketplace/terraform
````
Below is the list of parameters in **installer_envs** file, which needs to be updated with user specific info, before continuing with the installation.
- **RANDOM_ID**=<#4 character alphanumeric value. All the resources created as part of installation setup will have this suffix. Example:- 1a1b >
- **PATROL_KEYFILE**=<#Full path of the service account key file created in installer project>
- **PATROL_PROJECTID**=<#Installer Project ID>
- **MONITOR_PROJECTID**=<#Monitor Resource ID>
- **REGION**=<#Region name in which the Installer Project assets (Compute and CloudSQL) will be created. Example:- us-central1>
- **ZONE**=<#Zone name in which the Installer Project assets will be created. Example:- us-central1-c>
- **NETWORK_NAME**=<#Network name on which the assets will be created. CAN BE default ALSO>
- **PATROL_DOMAIN_NAME**=<#Domain name reserved to access Biarca Patrol dashboard>
- **LOADBALACER_IP_NAME**=<# Reserved External Static IP name>
- **LOADBALACER_IP**=<#Reserved External Static IP>
- **GCP_ORGANIZATION**=<#If the monitoring project is under a GCP organization, provide the domain name of the same. If monitoring project is NOT under any GCP organization, then MANDATORILY provide a value "No organization">
- **SENDGRID_APIKEY**=<#Create a Sendgrid key, which is used to send forseti notifications and provide the key here.
- **FORSETI_EMAIL_SENDER**=<#Email ID of Forseti notification Email sender>
- **FORSTI_EMAIL_RECIPIENT**=<#Email ID of Forseti notification Email recipient>
- **GSUITE_SUPER_ADMIN_EMAIL**=<#Email ID of GSUITE SUPER ADMIN>
- **SLACK_WEBHOOK_URL**=<#Slack webhook URL to notify forseti violations and event changes in monitoring resources>
- **SCHEDULER_REGION**=<#Region in which cloud scheduler will be created for scheduling forseti scans>
- **PATROL_STATS_TIME**=<#Time frame in minutes to update Biarca Patrol stats info. PLEASE NOTE THAT THE VALUE SHOULD BE ABOVE 15. Example:- 15>

**Note:** If Installer Project & Monitoring project are same, provide the same values for  ***PATROL_PROJECTID*** & ***MONITOR_PROJECTID***.
### 3.5 Creating Patrol Specific GCP Resources
Navigate to the path `<Path to Patrol-installer>/patrol-k8s-marketplace/terraform` and execute the below command to install the required GCP resources in the installer project.
````
$ bash installer.sh
````
As part of the script execution, when prompted for a value provide 'yes'.

`Note: Post successful completion of the script, few values will be displayed at the end of the script. Those values MUST be provided in the Marketplace UI during the Patrol app installation`
### 3.4 Patrol Installation from GCP Marketplace
In the GCP Console, select Installer project and then from the navigation menu click on  Marketplace and search for "Patrol". 
Follow the on-screen instructions and provide the required input values that were used for GCP assets creation as part of section [3.4] to populate the form.
## 4. Post Installation Steps
There are few manual steps which needs to be done post successful installation of Patrol application from marketplace.
### 4.1 Enabling IAP
To control who can access the Biarca Patrol UI, perform the below steps and configure IAP.
In the GCP Console, navigate to Security > Identity-Aware Proxy and Follow the below steps:

`Note: If IAP is already not enabled, Enable it. Click on CONFIGURE CONSENT SCREEN and select "Internal" option. Click on 'Next' button. Provide an application name (can be anything) and click on 'Save' Button. Navigate back to Identity-Aware Proxy page.`

- Click on **HTTPS RESOURCES** tab and Enable the toggle button beside the entry **patrol-ui-<RANDOM_ID>** to enable IAP for UI service. A pop up window is displayed.
- Select the Checkbox  and click on**Turn ON**
- Select the checkbox of the**patrol-ui-<RANDOM_ID>** (created as part of the above step). A panel is displayed on the right side.
- Click on the **ADD MEMBER** button.
- In the New members box, provide an **email id** and from the Roles drop down, select **Cloud IAP -> IAP-Secured Web App User**.

`Note:- It takes around 5 minutes for the DNS record and IAP to get updated. `
### 4.2 Update Service Accounts
Post successful installation of Biarca Patrol, in the installer project execute the below to remove the Owner role & Security Admin role attached to the service accounts.
````
$ cd <Path to patrol-installer>/patrol-k8s-marketplace/
$ bash remove_serviceaccount_roles.sh
````

## 5. UnInstalling Patrol
To uninstall the Patrol app from the marketplace, follow the below steps. All the GCP Resources which are created as part of the installation will be removed.
`Note: Before performing the below, make sure that the installer service account has Project Owner role and monitor service account has Security Admin role.`
Execute the below Steps:
1. From **Biarca Patrol UI -> Dashboard**, delete all the project(s).
2. From **Biarca Patrol UI -> Resource Monitoring**, delete all the project(s) which were added post installation.
3. From GCP Console delete “IAP Secrets”. If the installer project is used for multiple projects then it would be difficult to find out the appropriate IAP secret as a unique name will be created for secrets at the time of installation.
3.1 In order to identify the IAP secret for the specific project follow the below steps:
   - Now navigate to "**Menu > IAM & Admin > Identity-Aware Proxy**”.
   - Under **HTTPS Resources** right click on the 3 dots  for the web-browser and select **Edit OAuth Client**.
   - Copy the **Name** and **Client ID** of the project.
   - Now Navigate to **Menu > APIs & Services > Credentials**
   - Under the section **OAuth 2.0 Client IDs** click the *check-box* for the project you copied the **Name** and **Client ID**.
   - On the top click on **Delete** option.
4. Delete the sinks created when event-trigger is enabled.
   - Navigate to **Menu > Logging > Logs Router**.
   - Select the sink to be deleted and click on *Delete* on the top.

**Note: Post-installation if you have deleted the installer machine, execute the commands from the section [2.1]**
5. Navigate to `<Path to Patrol-installer>/patrol-k8s-marketplace/app-data`
6. Create a new file with name **'uninstall.envs'** and provide the below details.
  - PROJECT_ID=<Project-ID of the Installer Project>
  - PATROL_OWNER_SA=<Full Path of the Service Account Key file> # Mentioned in section [3.3] for PATROL_KEYFILE
  - MONITOR_OWNER_SA=<Full Path of the Service Account Key file> # Mentioned in Section [3.3] for PATROL_KEYFILE
  - SCANNER_BUCKET=<Patrol Scanner Bucket Name which starts with prefix 'patrol-scanner'>
  - REGION=<GCP Region in which the Kubernetes Cluster Created> # Ex: 'us-central1'
  - PATROL_KUBERNETES_CLUSTER_NAME=<Name of the Kubernetes cluster which starts with prefix 'patrol-kube-cluster'>
  - PATROL_ZONE=<GCP zone in which the Kubernetes Cluster Created> # Ex: 'us-central1-a'

7. Execute the below commands.
````
$ bash uninstall.sh
````
As part of the script execution, when prompted for a value provide 'yes'.

`Note :- The above script would not delete IAP secrets, External Static IP and DNS record. These need to be removed manually.`
