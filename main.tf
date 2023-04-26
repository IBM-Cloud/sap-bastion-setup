module "pre-init" {
  source = "./modules/pre-init"
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
  SSH-SOURCE-IP-CIDR-ACCESS = var.SSH-SOURCE-IP-CIDR-ACCESS
  count                     = (var.ADD-SOURCE-IP-CIDR == "yes" ? 1 : 0)
}

module "volumes" {
  source         = "./modules/volumes"
  depends_on     = [module.vpc, module.vpc-subnet]
  ZONE           = var.ZONES[0]
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME       = var.HOSTNAME
  VOL_PROFILE    = "custom"
  VOL_IOPS       = "3000"
  VOL1           = var.VOL1
}

module "vsi" {
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
  VOLUMES_LIST   = module.volumes.volumes_list
}

module "install-prereq" {
  source          = "./modules/install-prereq"
  depends_on      = [module.vsi]
  IP              = module.vsi.FLOATING-IP
  private_ssh_key = var.private_ssh_key
}
