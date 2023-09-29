# Automation script for SAP solutions using  a BASTION&STORAGE setup deployment throught Terraform and IBM Schematics.


## Description
This Terraform example for IBM Cloud Schematics demonstrates how to  perform an automated deployment of  **SAP BASTION with 3 zones support in the VPC and STORAGE setup** on top of **Red Hat Enterprise Linux 8.6**. It shows how to deploy an IBM Cloud Gen2 VPC with a bastion host with secure remote SSH access.

The intended usage is for remote software installation using Terraform remote-exec and Ansible playbooks executed by Schematics.

The example and Terraform modules only seek to implement a 'reasonable' set of best practices for bastion host configuration. Your own Organization could have additional requirements that should be applied before the deployment.


**It contains:**  
- Terraform scripts for deploying a VPC, Subnet, Security Group with default and custom rules, a Public Gateway for SNAT, a volume and a VSI.
- Bash scripts to install  the prerequisites for SAP BASTION&STORAGE VSI and other SAP solutions.

## Prerequisites
In order to apply the steps from this article, you should have a general understanding of IBM VPC and VSIs. To run the example in IBM Cloud Schematics, you will also need an [IBM Cloud account](https://cloud.ibm.com/registration?cm_sp=ibmdev-_-developer-articles-_-cloudreg). The deployed resources  are chargeable.

## IBM Cloud API Key
For the script configuration add your IBM Cloud API Key variable under IBM SCHEMATICS,  "SETTINGS" menu, editing the variable "IBMCLOUD_API_KEY" and  using sensitive option.

## VSI Configuration
The VSI is configured with Red Hat Enterprise Linux 8.6 (amd64), has a minimal of two SSH keys configured to be accessed by the root user and one storage volume as described below,  to be filled in, under the "SETTINGS" menu, variables fields in IBM Schematics.
The VSI will be deployed in the first zone, first subnet (chosen from a list of zones, subnets), specified by the user.  The same is true for the VSI volume, which will be deployed in the first zone.
The storage volume is mounted under "/storage" path, and can be accessed with the user "storage" via  your "PRIVATE_SSH_KEY" added as a variable.

**Software configuration:**
- Terraform - an open-source infrastructure as code software tool created by HashiCorp
- Ansible - an open-source software provisioning and configuration management tool.
- The IBM Cloud® Command Line Interface provides commands for managing resources in IBM Cloud.


## SAP Bastion Input variables
The solution is configured by editing your variables in your workspace:
Edit your VPC, Subnet, Custom ssh source IP/CIDR Access, Hostname, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:
A Security Group will be automatically created based on IBM policy.

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | Input id_rsa private key content (Sensitive* value).
SSH_KEYS | List of SSH Keys IDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH IDS from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
RESOURCE_GROUP | EXISTING Resource Group for VPC, subnet, FLOATING IP, security group, VSI and Volume resources. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONES | The cloud zone where to deploy the solution, list of zones name. Can be multiple values seprated by commas. ZONEs name should be a list of strings, zones should be 1 or less than or equal to 3. <br />  Example ["eu-de-1", "eu-de-2", "eu-de-3"]
SUBNETS | The list of subnet names. Can be multiple values seprated by commas. SUBNETs name should be a list of strings, subnets should be 1 or less than or equal to 3.  <br /> Example ["sn-23000000-01", "sn-23000000-02", "sn-23000000-03"]. <br /> The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets)
VPC_EXISTS | Please mention if the chosen VPC exists or not (use 'yes' or 'no'). If you choose 'no' as an option, a new VPC will be created. If the VPC_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS.If VPC_EXISTS is set to no, a new VPC will be created, along with all supplied SUBNETS in the provided ZONES.
VPC | The name of the VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
ADD_SOURCE_IP_CIDR | Please mention if you want to add a range of IPs or CIDR (use 'yes' or 'no'). If you choose 'yes' as an option, The IP/s or CIDR will be added as source INBOUND SSH access to the BASTION server.
SSH_SOURCE_IP_CIDR_ACCESS | List of CIDR/IPs for source SSH access.<br /> Sample input: [ "10.243.64.0/27" , "89.76.89.156" , "5.15.114.40" , "161.156.167.199" ]
HOSTNAME | The Hostname for the VSI. The hostname must have up to 13 characters.
PROFILE |  The profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br /> Default value: "bx2-2x8"
IMAGE | The OS image used for the VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-8-minimal-amd64-2
VOL1 [number] | The size for the disk in GB to be attached to the  BASTION VSI as storage for the SAP deployment kits. The mount point for the new volume is: "/storage". <br /> Default value: 100 GB.

Obs: Sensitive* - The variable value is not displayed in your workspace details after it is stored.


## VPC Configuration

The Security Rules are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.
- Option to Allow inbound ssh traffic with a custom source IP/CIDR list.



## Files description and structure:

 - `modules` - directory containing the terraform modules
 - `main.tf` - contains the configuration of the VSI for SAP single tier deployment.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP, Public IP)
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.



## Steps to reproduce:

1.  Be sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy this
    example
3.  Create the Schematics workspace:
   1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
       - Click Create a workspace.   
       - Enter a name for your workspace.   
       - Click Create to create your workspace.
    2.  On the workspace **Settings** page, enter the URL of this example in
    the Schematics examples Github repository.
     - Select the Terraform version: Terraform 0.12.
     - Click **Save template information**.
     - In the **Input variables** section, review the default input
        variables and provide alternatives if desired. The only
        mandatory parameter is the name given to the SSH key that you
        uploaded to your IBM Cloud account.
      - Click **Save changes**.

4.  From the workspace **Settings** page, click **Generate plan** 
5.  Click **View log** to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the bastion host, the hostname and the VPC.  

## Outputs example:

FLOATING_IP = "161.156.90.230"<br />
HOSTNAME = "sapbastionsch"<br />
PRIVATE_IP = "10.243.64.4"<br />
REGION = "eu-de"<br />
SECURITY_GROUP = "bastion-sg-sapvpcbastion"<br />
VPC = "sapvpcbastion"<br />


The Terraform version used for deployment should be >= 1.5.5. 
Note: The deployment was tested with Terraform 1.5.5 and 1.5.7

### Related links:
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
