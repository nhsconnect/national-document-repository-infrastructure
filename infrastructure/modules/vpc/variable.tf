# Availability zones for Amazon region
variable "standalone_vpc_tag" {
  description = "This is the tag assigned to the standalone VPC that should be created manaully before the first run of the infrastructure."
  type        = string
}

variable "standalone_vpc_ig_tag" {
  description = "This is the tag assigned to the standalone VPC internet gateway that should be created manually before the first run of the infrastructure."
  type        = string
}

variable "availability_zones" {
  description = "This list specifies all the Availability Zones that will have a pair of public and private subnets."
  type        = list(string)
}

# Toggles
variable "enable_dns_support" {
  description = "This allows AWS DNS support to be switched on or off."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "This allows AWS DNS hostname support to be switched on or off."
  type        = bool
  default     = true
}

variable "enable_private_routes" {
  description = "Whether to enable NAT routing for private subnets."
  type        = bool
  default     = false
}

# CIDR Definitions
variable "ig_cidr" {
  description = "This specifies the CIDR block for the internet gateway."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ig_ipv6_cidr" {
  description = "This specifies the IPV6 CIDR block for the internet gateway."
  type        = string
  default     = "::/0"
}

variable "vpc_cidr" {
  description = "This specifices the VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "endpoint_gateway_services" {
  description = "List of AWS services to enable as VPC gateway endpoints."
  type        = list(string)
}

variable "endpoint_interface_services" {
  description = "List of AWS services to enable as VPC interface endpoints."
  type        = list(string)
}

variable "security_group_id" {
  description = "The security group ID to associate with VPC endpoints."
}

variable "num_public_subnets" {
  description = "The number of public subnets to create across availability zones."
  type        = number
}

variable "num_private_subnets" {
  description = "The number of private subnets to create across availability zones."
  type        = number
}

# Tags
variable "environment" {
  description = "The environment tag used to classify resources (e.g., dev, staging, prod)."
  type        = string
}

variable "owner" {
  description = "The owner tag used to identify responsible team or individual."
  type        = string
}
