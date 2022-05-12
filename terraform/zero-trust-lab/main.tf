provider "aws" {}

module "vulnerable-vpc" {
    source           = "../modules/vpc"
    vpc              = var.vulnerable-vpc
    prefix-name-tag  = var.prefix-name-tag
    subnets          = var.vulnerable-vpc-subnets
    route-tables     = var.vulnerable-vpc-route-tables
    security-groups  = var.vulnerable-vpc-security-groups
    ec2-instances    = var.vulnerable-vpc-instances
    global_tags      = var.global_tags
}

module "attack-vpc" {
    source          = "../modules/vpc"
    vpc             = var.attack-vpc
    prefix-name-tag = var.prefix-name-tag
    subnets         = var.attack-vpc-subnets
    route-tables    = var.attack-vpc-route-tables
    ec2-instances   = var.attack-vpc-instances
    security-groups = var.attack-vpc-security-groups
    global_tags     = var.global_tags
}

module "security-vpc" {
    source          = "../modules/vpc"
    vpc             = var.security-vpc
    prefix-name-tag = var.prefix-name-tag
    subnets         = var.security-vpc-subnets
    route-tables    = var.security-vpc-route-tables
    security-groups = var.security-vpc-security-groups
    global_tags     = var.global_tags
}

locals {
  vpcs = {
    "${module.vulnerable-vpc.vpc_details.name}"  : module.vulnerable-vpc.vpc_details,
    "${module.attack-vpc.vpc_details.name}"      : module.attack-vpc.vpc_details,
    "${module.security-vpc.vpc_details.name}"    : module.security-vpc.vpc_details
  }
}

module "transit-gateway" {
  source          = "../modules/transit-gateway"
  transit-gateway = var.transit-gateway
  prefix-name-tag = var.prefix-name-tag
  global_tags     = var.global_tags
  vpcs            = local.vpcs
  transit-gateway-associations = var.transit-gateway-associations
  transit-gateway-routes       = var.transit-gateway-routes
}

module "vpc-routes" {
  source          = "../modules/vpc_routes"
  vpc-routes      = merge(var.vulnerable-vpc-routes, var.attack-vpc-routes, var.security-vpc-routes)
  vpcs            = local.vpcs
  tgw-ids         = module.transit-gateway.tgw-ids
  ngfw-data-eni   = module.vm-series.ngfw-data-eni
  prefix-name-tag = var.prefix-name-tag
}

module "panorama" {
  source                = "../modules/panorama"
  panorama_product_code = var.panorama_product_code
  panorama_version      = var.panorama_version
  panorama              = var.panorama
  ssh_key_name          = module.vulnerable-vpc.ssh_key_name
  prefix-name-tag       = var.prefix-name-tag
  vpc_name              = module.security-vpc.vpc_name
  subnet_ids            = module.security-vpc.subnet_ids
  security_groups       = module.security-vpc.security_groups
  global_tags           = var.global_tags
}

module "vm-series" {
  source          = "../modules/vm-series"
  fw_product_code = var.fw_product_code
  fw_version      = var.fw_version
  firewalls       = var.firewalls
  fw_interfaces   = var.firewall-interfaces
  ssh_key_name    = module.vulnerable-vpc.ssh_key_name
  prefix-name-tag = var.prefix-name-tag
  vpc_name        = module.security-vpc.vpc_name
  subnet_ids      = module.security-vpc.subnet_ids
  security_groups = module.security-vpc.security_groups
  global_tags     = var.global_tags

  depends_on      = [ module.panorama ]
}

output "VM-Series-Image-ID" {
  value = module.vm-series.VM-Series-Image-ID.id
}

output "Panorama-Image-ID" {
  value = module.panorama.Panorama-Image-ID.id
}