variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Exactly two availability zones."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "availability_zones must contain exactly two distinct availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDRs, one for each availability zone."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs must contain exactly two CIDR blocks."
  }
}

variable "private_app_subnet_cidrs" {
  description = "Two private application subnet CIDRs, one for each availability zone."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_cidrs) == 2
    error_message = "private_app_subnet_cidrs must contain exactly two CIDR blocks."
  }
}

variable "database_subnet_cidrs" {
  description = "Two isolated database subnet CIDRs, one for each availability zone."
  type        = list(string)

  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "database_subnet_cidrs must contain exactly two CIDR blocks."
  }
}

variable "common_tags" {
  description = "Tags applied consistently to every resource in this module."
  type        = map(string)
  default     = {}
}
