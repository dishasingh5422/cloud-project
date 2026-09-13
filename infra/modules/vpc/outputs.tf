output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by availability zone."
  value       = { for availability_zone, subnet in aws_subnet.public : availability_zone => subnet.id }
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs keyed by availability zone."
  value       = { for availability_zone, subnet in aws_subnet.private_app : availability_zone => subnet.id }
}

output "database_subnet_ids" {
  description = "Database subnet IDs keyed by availability zone."
  value       = { for availability_zone, subnet in aws_subnet.database : availability_zone => subnet.id }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "route_table_ids" {
  description = "Route table IDs for the public, application, and database network tiers."
  value = {
    public      = aws_route_table.public.id
    private_app = aws_route_table.private_app.id
    database    = aws_route_table.database.id
  }
}
