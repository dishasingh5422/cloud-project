output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by availability zone."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs keyed by availability zone."
  value       = module.vpc.private_app_subnet_ids
}

output "database_subnet_ids" {
  description = "Isolated database subnet IDs keyed by availability zone."
  value       = module.vpc.database_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = module.vpc.internet_gateway_id
}
