
variable "vulnerable-vpc" { default = {} }
variable "vulnerable-vpc-subnets" { default = [] }
variable "vulnerable-vpc-route-tables" { default = [] }
variable "vulnerable-vpc-security-groups" { default = [] }
variable "vulnerable-vpc-instances" { default = [] }
variable "vulnerable-vpc-routes" { default = [] }

variable "attack-vpc" { default = {} }
variable "attack-vpc-subnets" { default = [] }
variable "attack-vpc-route-tables" { default = [] }
variable "attack-vpc-security-groups" { default = [] }
variable "attack-vpc-instances" { default = [] }
variable "attack-vpc-routes" { default = [] }

variable "security-vpc" { default = {} }
variable "security-vpc-subnets" { default = [] }
variable "security-vpc-route-tables" { default = [] }
variable "security-vpc-security-groups" { default = [] }
variable "security-vpc-routes" { default = [] }

variable "fw_version" { default = "" }
variable "fw_product_code" { default = [] }
variable "fw_instance_type" { default = "" }
variable "panorama_version" { default = ""}
variable "panorama_product_code" { default = ""}
variable "panorama_instance_type" { default = ""}

variable "firewalls" { default = [] }
variable "panorama" { default = {} }
variable "firewall-interfaces" { default = [] }
variable "nat_gateways" { default = {} }
variable "gateway_load_balancer" { default = {} }
variable "gateway_load_balancer_endpoints" { default = {} }

variable "transit-gateway" { default = {} }
variable "transit-gateway-associations" { default = {} }
variable "transit-gateway-routes" { default = {} }

variable "prefix-name-tag" { default = "" }

variable "global_tags" { default = {} }