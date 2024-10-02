module "pre-init" {
  source = "./modules/pre-init"
  count  = var.DESTROY_BASTION_SERVER_VSI == false ? 1 : 0
}

module "vpc" {
  source         = "./modules/vpc"
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC
  count          = var.VPC_EXISTS == "no" ? 1 : 0
}

module "validate-subnet" {
  source         = "./modules/validate-subnet"
  count          = var.VPC_EXISTS == "yes" ? 1 : 0
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC
  SUBNET_ZONE    = local.subnets_zones
}

module "vpc-subnet" {
  depends_on     = [module.vpc, module.validate-subnet]
  source         = "./modules/vpc/subnet"
  for_each       = var.VPC_EXISTS == "yes" ? one(module.validate-subnet[*].SUBNETS_WITH_ZONES) : local.subnets_zones
  ZONE           = each.value
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC
  SUBNET         = each.key
  HOSTNAME       = var.HOSTNAME
}

module "sg-sch-ssh" {
  count          = var.DESTROY_BASTION_SERVER_VSI == false ? 1 : 0
  depends_on     = [module.vpc, module.vpc-subnet, module.pre-init]
  source         = "./modules/vpc/security-group/sg-sch-ssh"
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC
  HOSTNAME       = var.HOSTNAME
}

module "vpc-security-group" {
  depends_on     = [module.vpc, module.vpc-subnet]
  source         = "./modules/vpc/security-group"
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC
  HOSTNAME       = var.HOSTNAME
}

module "custom-ssh" {
  depends_on                = [module.vpc, module.vpc-subnet]
  source                    = "./modules/vpc/security-group/custom-inbound-ssh"
  RESOURCE_GROUP            = var.RESOURCE_GROUP
  VPC                       = var.VPC
  HOSTNAME                  = var.HOSTNAME
  SSH_SOURCE_IP_CIDR_ACCESS = var.SSH_SOURCE_IP_CIDR_ACCESS
  count                     = (var.ADD_SOURCE_IP_CIDR == "yes" ? 1 : 0)
}

module "volumes" {
  count                 = var.DESTROY_BASTION_SERVER_VSI == false ? 1 : 0
  source                = "./modules/volumes"
  depends_on            = [module.vpc, module.vpc-subnet]
  ZONE                  = var.ZONES[0]
  RESOURCE_GROUP        = var.RESOURCE_GROUP
  HOSTNAME              = var.HOSTNAME
  VOL_PROFILE           = "general-purpose"
  VOL1                  = var.VOL1
}

module "vsi" {
  count          = var.DESTROY_BASTION_SERVER_VSI == false ? 1 : 0
  source         = "./modules/vsi"
  depends_on     = [module.volumes]
  ZONE           = var.ZONES[0]
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC
  SUBNET         = var.SUBNETS[0]
  HOSTNAME       = var.HOSTNAME
  PROFILE        = var.PROFILE
  IMAGE          = var.IMAGE
  SSH_KEYS       = var.SSH_KEYS
  sg-ssh         = one(module.custom-ssh[*].sg-ssh)
  securitygroup  = one(module.vpc-security-group[*].securitygroup)
  sg-sch-ssh     = one(module.sg-sch-ssh[*].sg-sch-ssh)
  VOLUMES_LIST   = module.volumes[0].volumes_list
}

module "install-prereq" {
  count           = var.DESTROY_BASTION_SERVER_VSI == false ? 1 : 0
  source          = "./modules/install-prereq"
  depends_on      = [module.vsi]
  IP              = module.vsi[0].FLOATING-IP
  private_ssh_key = var.PRIVATE_SSH_KEY
}


module "secretmanager" {
  source              = "./modules/secretmanager"
  sm_name = "${var.VPN_PREFIX}_secretmanager"
  REGION = var.REGION
  RESOURCE_GROUP_ID   = data.ibm_resource_group.group.id
  SM_PLAN             = var.SM_PLAN
  IBMCLOUD_API_KEY = var.IBMCLOUD_API_KEY
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 700 "
  }
  depends_on = [module.secretmanager]
}

module "certificate" {
  source              = "./modules/certificate"
  depends_on = [null_resource.wait]
  instance_id = data.local_file.sm_guid.content
  resource_group_id   = data.ibm_resource_group.group.id
  name                = "${var.VPN_PREFIX}_cert"
  REGION       =  var.REGION
}

module "vpn" {
  source            = "./modules/vpn"
  depends_on	      = [ module.certificate,module.vpc, module.vpc-subnet, module.vpc-security-group]
  VPN_PREFIX        = var.VPN_PREFIX
  resource_group_id = data.ibm_resource_group.group.id
  resource_group_id_bastion = module.vpc-security-group.securitygroup
  certificate_crn   = module.certificate.server_cert_crn
  VPN_CLIENT_IP_POOL = var.VPN_CLIENT_IP_POOL
  zone              = var.ZONES[0]
  VPC               = var.VPC
  SUBNETS           = var.SUBNETS
}

module "ovpn" {
  source       = "./modules/ovpn"
  count  = var.DESTROY_BASTION_SERVER_VSI == false ? 1 : 0
  depends_on	= [ module.vpn,module.vsi ]
  vpn_hostname = module.vpn.VPN_HOSTNAME
  ca           = module.certificate.ca
  client_cert  = module.certificate.client_cert
  client_key   = module.certificate.client_key
  bastion_ip   = length(module.vsi) > 0 ? module.vsi[0].FLOATING-IP : null
  private_key  = var.PRIVATE_SSH_KEY
}
