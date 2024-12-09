# Deployment Server (BASTION server) provisioning and the main VPC Infrastrucure configuration for SAP solutions using Terraform and IBM Schematics

## Description
This automation solution is designed for the deployment of an IBM Cloud Gen2 VPC with a BASTION (Deployment Server) host with secure SSH access. It is creating a **SAP Deployment Server (BASTION Server), having support for three zones in the VPC, and the STORAGE setup** on top of **Red Hat Enterprise Linux 8.8**.

The automatic deployment of a BASTION server (Deployment Server) is required before running the automation to deploy an SAP system in IBM Cloud VPC. The intended usage of the Deployment Server (BASTION Server) is for the remote execution of the Ansible playbooks using Terraform remote-exec in Schematics, at the automatic deployment of the SAP systems but, it can also be used, for example, as a Jump Host, to maintain and administer all SAP solutions within its respective IBM Cloud VPC region. This automation provides a customizable security group and subnets, to enable access, in the corresponding Cloud zones to the SAP/DB VSI's. The Floating IP allows the Deployment Server (BASTION Server) host access to the internet, so that SAP and DB kit files can be downloaded. On top of this, a dedicated VPN solution will be automatically created for you and will provide direct access to the private IP addressing plan of your future SAP servers.

The following software packages are installed on the Deployment Server (BASTION Server):
- Terraform version 1.9.2
- the latest available versions of:
    - Ansible
    - Python3
    - IBM Cloud CLI and IBM Cloud Plugins for CLI: vpc-infrastructure, schematics, cloud-object-storage

Terraform is an open source infrastructure as code software tool created by HashiCorp. The Terraform modules are implementing a 'reasonable' set of best practices for the Deployment Server (BASTION Server) host configuration. Your own Organization could have additional requirements that should be applied before the deployment.

**It contains:**  
- Terraform scripts for deploying a VPC, Subnet, Security Group with default and custom rules, a Public Gateway for SNAT, a VSI with a volume, a Secrets Manager service instance and a VPN Client-to-site Solution . The automation has support for the following versions: Terraform >= 1.9.0 and IBM Cloud provider for Terraform >= 1.62.0.  
Note: The deployment was tested with Terraform 1.9.2
- Bash scripts to install the prerequisites for the Deployment Server (BASTION Server) & STORAGE VSI and for other SAP solutions.

The deployed IBM Cloud resources are chargeable.

## Contents:

- [1.1 VSI Configuration](#11-vsi-configuration)
- [1.2 VPC Configuration](#12-vpc-configuration)
- [1.3 Files description and structure](#13-files-description-and-structure)
- [2.1 Prerequisites](#21-prerequisites)
- [2.2 Executing the **deployment of the BASTION Server (Deployment Server)** and the **main VPC infrastructure configuration** in GUI (Schematics)](#22-executing-the-deployment-of-the-bastion-server-deployment-server-and-the-main-vpc-infrastructure-configuration-in-gui-schematics)
- [3.1 Related links](#31-related-links)

## 1.1 VSI Configuration

The VSI for the Deployment Server (BASTION Server) will be deployed in the first zone, first subnet, from the list of zones and subnets specified by the user, with Red Hat Enterprise Linux 8.8 (amd64) as Operating System and a storage volume with customized size. 

The VSI volume will also be provisioned in the first zone from the provided list. The `storage` volume is mounted under "/storage" path, and can be accessed with the user "storage" using the SSH key set in the "PRIVATE_SSH_KEY" variable. 

The provided SSH key UUIDs are configured in order to be used by the root user to connect to the VSI. The BASTION Server is accessed through the Floating IP.

## 1.2 VPC Configuration

The Security Rules are:

- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.
- Option to Allow inbound SSH traffic with a custom source IP/CIDR list.

## 1.3 VPN Configuration

For the VPN Solution a Secrets Manager instance will be provisioned and 2 Secrets provisioned inside: the server certificate and the client certificate; both will be used later on during the VPN creation and used also in the ovpn file generated for the connection; they can be seen under the Secrets Manager's page, under Secrets and use the option to "View secret".

The VPN server will have a dedicated Security Group, which during the creation will open port UDP 443 for all source ip addresses; this can be of course later on customized according to the customer's neeeds.

A rule will be added also for the bastion's Security Group to allow all traffic from the VPN's Security Group, allowing traffic from the VPN to the Security Group of the server. Later on, if other Security Groups will be added to the VPC and you would want them to be accessible via the VPN solution, the same rule should be configured for those as well.

The automation script will generate on the bastion itself an ovpn profile file for your OpenVPN client, which you will need to download from the bastion and import in your OpenVPN client.

## 1.4 Files description and structure

- `modules` - directory containing the Terraform modules
- `main.tf` - contains the configuration of the VSI.
- `output.tf` - contains the code for the information to be displayed after the Cloud Resources are created (Hostname, Private IP, Floating IP, Subnet, VPC, Region, Security Group, Secrets Manager ID, VPN Server Name, the OpenVPN file created).
- `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
- `terraform.tfvars` - contains the IBM Cloud API key referenced in provider.tf (dynamically generated)
- `variables.tf` - contains variables for the VPC and VSI
- `versions.tf` - contains the minimum required versions for Terraform and IBM Cloud provider.

## 2.1 Prerequisites

- A general understanding of IBM VPC and VSIs is necessary. 
- An [IBM Cloud account](https://cloud.ibm.com/registration?cm_sp=ibmdev-_-developer-articles-_-cloudreg)
- A Resource Group for the Cloud resources. A new Resource Groups can be created [here](https://cloud.ibm.com/account/resource-groups)
- An IBM Cloud API Key, which can be added in IBM SCHEMATICS, "SETTINGS" menu, by editing the variable "IBMCLOUD_API_KEY" and using sensitive option. The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
- An IAM service-to-service authorization for your VPN server and IBM Cloud Secrets Manager; this can be created following the steps under 'Creating an IAM service-to-service authorization' [here](https://cloud.ibm.com/docs/vpc?topic=vpc-client-to-site-authentication#creating-iam-service-to-service)

## 2.2 Executing the **deployment of the BASTION Server (Deployment Server)** and the **main VPC infrastructure configuration** in GUI (Schematics)

### SAP Deployment Server (BASTION Server) and VPC Input variables
The following variables can be configured by editing the values in the Schematics workspace: VPC, SUBNET, SSH_SOURCE_IP_CIDR_ACCESS, HOSTNAME, PROFILE, IMAGE, SSH_KEYS and the additional disk size.
A Security Group will be automatically created based on IBM policy.

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
PRIVATE_SSH_KEY | id_rsa private key content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the deployment.
SSH_KEYS | List of SSH Keys UUIDs that are allowed to connect to the VSI via SSH, as root user. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH IDS from IBM Cloud):<br /> [ "r010-57bdv315-f9e5-4dgf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d9sgg36b2c7e" ]
RESOURCE_GROUP | EXISTING Resource Group for VPC, subnet, FLOATING IP, security group, VSI and Volume resources. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are available [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONES | A list with the IBM Cloud zones accessible from the Deployment Server (BASTION Server), where the SAP solutions will be later deployed. <br />Multiple values separated by comma are allowed. ZONE names must be a list of strings. <br />The list should contain at least one zone name and maximum three zone names. Example [\"eu-de-1\", \"eu-de-2\", \"eu-de-3\"]
SUBNETS | A list of subnets to be created or existing ones, corresponding to the IBM Cloud zones selected. Multiple values separated by comma are allowed. SUBNET names must be a list of strings. The list must contain at least one subnet name and maximum three subnet names. <br />Example ["sn-23000000-01", "sn-23000000-02", "sn-23000000-03"]. <br /> The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets)
VPC_EXISTS | Specifies if the VPC, having the provided name, already exists. Allowed values: 'yes' and 'no'. If the value 'no' is chosen, a new VPC will be created along with all supplied SUBNETS in the provided ZONES. If the VPC_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS.
VPC | The name of the EXISTING / NEW VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
ADD_SOURCE_IP_CIDR | Specifies if a range of IP addresses or CIDR should be added as source INBOUND SSH access to the Deployment Server (BASTION server). Allowed values: 'yes' and 'no'. Default value: 'no'
SSH_SOURCE_IP_CIDR_ACCESS | The list of CIDR/IPs for source SSH access. Multiple values separated by comma are allowed. The sample default value must be changed with your own CIDR/IPs.<br /> Sample input: [ "10.243.64.0/27" , "89.76.89.156" , "5.15.114.40" , "161.156.167.199" ]
HOSTNAME | Deployment Server (BASTION Server) VSI Hostname. The hostname must have up to 13 characters.
PROFILE |  Deployment Server (BASTION Server) VSI Profile. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br /> Default value: "bx2-2x8"
IMAGE | Deployment Server (BASTION Server) VSI OS Image. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-8-minimal-amd64-2
VOL1 [number] | The size, in GB, of the disk to be attached to the Deployment Server (BASTION Server) VSI, for later use as storage for the SAP deployment kits. The mount point for the new volume is: "/storage". <br /> Default value: 100 GB.
VPN_CREATE | Specifies if you want a VPN solution to be added to your bastion setup. If 'yes' a VPN solution will be automatically deployed for you, allowing you access to the private ip addressing space of your VPC.
VPN_PREFIX | The prefix to use for the VPN related elements. The prefix set under this variable will be added to the Secrets Manager instance created, also used as a prefix for the VPN's Security Group and it will be used as a name for the VPN server created.
VPN_NETWORK_PORT_PROTOCOL | The protocol to be used for the VPN solution. (must be either 'tcp' or 'udp')
VPN_NETWORK_PORT_NUMBER | The port number to be used for the VPN solution. (must be between 1 and 65535)
SM_PLAN | The pricing plan that you want to use for the Secrets Manager instance, provided as a plan ID. Use 869c191a-3c2a-4faf-98be-18d48f95ba1f for trial or 7713c3a8-3be8-4a9a-81bb-ee822fcaac3d for standard.
VPN_CLIENT_IP_POOL | Optional variable to specify the CIDR for VPN client IP pool space. This is the IP space that will be used by machines connecting with the VPN. You should only need to change this if you have a conflict with your local network.
DESTROY_BASTION_SERVER_VSI | For the initial deployment, should remain set to false. After the initial deployment, in case there is a wish to destroy the Deployment Server (BASTION Server) VSI, but preserve the rest of the Cloud resources (VPC, Subnet, Security Group, VPN Solution), in Schematics, the value must be set to true and then the changes must be applied by pressing the "Apply plan" button.


Obs: Sensitive* - The variable value is not displayed in your workspace details after it is stored.

### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the Deployment Server (BASTION Server) host. After you have created the SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to make the deployment
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

    In the output of the Schematics `Apply Plan` the public/private IP addresses
of the Deployment Server (BASTION Server) host, the hostname, the VPC, the Region, the Subnet, the Security Group and the Secrets Manager instance ID, the VPN solution details will be displayed.

### Output sample:

```
FLOATING_IP = "163.66.82.31"
HOSTNAME = "bastion-test-vpn-cli"
OVPN_FILE = "/root/OpenVPN.ovpn"
PRIVATE_IP = "10.249.0.4"
REGION = "ca-tor"
SECURITY_GROUP = "bastion-sg-bastion-test-vpn-cli"
SUBNET = ["sap-subnet-1", "sap-subnet-2", "sap-subnet-3"]
VPC = "sap-vpc-test-cli"
VPN_HOSTNAME = "b6dde418085d.ca-tor.vpn-server.appdomain.cloud"
```

8. Your ovpn file will be on the bastion server, under the OVPN_FILE path displayed in the output; please copy the file from there and distribute it to whom you might consider; they should import this file in their OpenVPN client; once connected, they will be able to reach the private ip addressing space of the bastion server.

The costs with the Deployment Server (BASTION Server) can be reduced in two ways:
1. by manually stopping the Deployment Server (BASTION Server) VSI and starting it again when needed. This operation ca be executed from [the list of available VSIs](https://cloud.ibm.com/vpc-ext/compute/vs).
2. by automatically removing the Deployment Server (BASTION Server) VSI (with the preservation of the already deployed VPC, Subnet, Security Group and VPN Solution) and creating a new Deployment Server (BASTION Server) VSI when needed. If this option is chosen, in the Schematics workspace for that Deployment Server (BASTION Server) the value for **`DESTROY_BASTION_SERVER_VSI`** must be changed from **false** to **true** and then the button "Apply plan" must be actioned. Later, a new Deployment Server (BASTION Server) VSI in the same VPC and with the same network configuration can be created in the same Schematics workspace, by changing the value for **`DESTROY_BASTION_SERVER_VSI`** from **true** to **false** and pushing the "Apply plan" button.

    **Important Notes:** In case the Deployment Server (BASTION Server) to be removed was used for the automatic deployment of SAP solutions from CLI, make sure that before destroying the VSI, the follwoing actions were performed:
    - if there are SAP solutions automatically deployed **from CLI** using the Deployment Server (BASTION Server) VSI to be removed, the deployment folder of each SAP solution should be securely saved on another device, to be used later, in case there will be a whish to automatically remove the resources created with the automation of that SAP solution.
    - when you create the new Deployment Server (BASTION Server) VSI (after the initial one was automatically removed), in the Schematics workspace for your Deployment Server (BASTION Server), the value for **`DESTROY_BASTION_SERVER_VSI`** must be changed again to **false**
    - if later on you would like to automatically remove the resources created during an automatic deployment of an SAP solution, the saved deployment folder must be copied on the new Deployment Server (BASTION Server) and the SAP kit files, used for deploying that solution, should be also present in the path which was specified for the deployment.

## 3.1 Related links:
- [Securely Access Remote Instances with a BASTION Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-BASTION-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
- [IBM Cloud client-to-site VPN servers](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
