
security-vpc = {
    name                 = "sec-vpc"
    cidr_block           = "10.3.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    internet_gateway     = true
}

security-vpc-route-tables = [
  { name = "cngfw-rt", "subnet" = "subnet" },
  { name = "tgw-rt", "subnet" = "tgw-subnet" }
]

security-vpc-routes = {
  sec-vpc-tgw-vul-vpc = {
    name          = "sec-vpc-tgw-vul-vpc"
    vpc_name      = "sec-vpc"
    route_table   = "cngfw-rt"
    prefix        = "10.1.0.0/16"
    next_hop_type = "transit_gateway"
    next_hop_name = "tgw"
  },
  sec-vpc-tgw-att-vpc = {
    name          = "sec-vpc-tgw-att-vpc"
    vpc_name      = "sec-vpc"
    route_table   = "cngfw-rt"
    prefix        = "10.2.0.0/16"
    next_hop_type = "transit_gateway"
    next_hop_name = "tgw"
  },
  sec-vpc-igw = {
    name          = "sec-vpc-igw"
    vpc_name      = "sec-vpc"
    route_table   = "cngfw-rt"
    prefix        = "0.0.0.0/0"
    next_hop_type = "internet_gateway"
    next_hop_name = "sec-vpc"
  },
  sec-vpc-ngfw = {
    name          = "sec-vpc-ngfw"
    vpc_name      = "sec-vpc"
    route_table   = "tgw-rt"
    prefix        = "0.0.0.0/0"
    next_hop_type = "network_interface"
    next_hop_name = "vmseries01-data"
  }
}

security-vpc-subnets = [
  { name = "subnet", cidr = "10.3.1.0/24", az = "a" },
  { name = "tgw-subnet", cidr = "10.3.0.0/24", az = "a" }
]

security-vpc-security-groups = [
  {
    name = "ngfw-sg"
    rules = [
      {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Permit All Internal traffic"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
]

transit-gateway = {
  name     = "tgw"
  asn      = "64512"
  route_tables = {
    security = { name = "from-sec-vpc"}
    spoke    = { name = "from-app-vpcs"}
  }
}

transit-gateway-associations = {
  "sec-vpc" = "from-sec-vpc",
  "vul-vpc" = "from-app-vpcs",
  "att-vpc" = "from-app-vpcs"
}

transit-gateway-routes = {
  "sec-vpc-to-vul-vpc-route" = {
    route_table = "from-sec-vpc"
    vpc_name    = "vul-vpc"
    cidr_block  = "10.1.0.0/16"
  },
  "sec-vpc-to-att-vpc-route" = {
    route_table = "from-sec-vpc"
    vpc_name    = "att-vpc"
    cidr_block  = "10.2.0.0/16"
  },
  "app-vpcs-to-sec-vpc-route" = {
    route_table = "from-app-vpcs"
    vpc_name    = "sec-vpc"
    cidr_block  = "0.0.0.0/0"
  }
}

fw_version = "10.2.1"
fw_product_code = ["hd44w1chf26uv4p52cdynb2o"]

panorama_version = "10.2.0"
panorama_product_code = ["eclz7j04vu9lf8ont8ta3n17o"]

firewalls = [
  {
    name              = "vmseries01"
    instance_type     = "m5.xlarge"
    bootstrap_options = { "hostname" = "qwikLABS-vmseries01" }
    interfaces = [
      { name = "vmseries01-mgmt", index = "0" },
      { name = "vmseries01-data", index = "1" },
    ]
  }
]

firewall-interfaces = [
  {
    name              = "vmseries01-data"
    source_dest_check = false
    subnet_name       = "subnet"
    private_ips       = ["10.3.1.200"]
    security_group    = "ngfw-sg"
  },
  {
    name              = "vmseries01-mgmt"
    source_dest_check = true
    subnet_name       = "subnet"
    private_ips       = ["10.3.1.100"]
    security_group    = "ngfw-sg"
  }
]

panorama = {
  name = "panorama"
  source_dest_check = true
  subnet_name = "subnet"
  private_ips = ["10.3.1.201"]
  security_group = "ngfw-sg"
  instance_type = "c5.4xlarge"
}