
management-vpc = {
    name                 = "mgmt-vpc"
    cidr_block           = "10.4.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    internet_gateway     = true
}

management-vpc-route-tables = [
  { name = "rt", "subnet" = "subnet" }
]

management-vpc-subnets = [
  { name = "subnet", cidr = "10.4.1.0/24", az = "a" }
]

management-vpc-security-groups = [
  {
    name = "sg"
    rules = [
      {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Permit All HTTPS inbound traffic"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Permit All SSH inbound traffic"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
]

panorama = {
  name              = "panorama"
  source_dest_check = true
  subnet_name       = "subnet"
  private_ips       = ["10.4.1.100"]
  security_group    = "sg"
  instance_type     = "m5.4xlarge"
  tplname           = "VM-tempstack"
  dgname            = "VM-DG"
  vm-auth-key       = "410447188942721"
  ami               = "ami-056f74fbb2c053685"
}