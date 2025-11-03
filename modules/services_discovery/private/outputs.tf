output "namespace_name" {
  description = "The Name of the private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.main.name
}
output "namespace_id" {
  description = "The ID of the private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "namespace_arn" {
  description = "The ARN of the private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.main.arn
}

output "service_arns" {
  description = "The ARNs of the discovered services"
  value       = { for k, v in aws_service_discovery_service.this : k => v.arn }
}


output "service_names" {
  description = "The ARNs of the discovered services"
  value       = { for k, v in aws_service_discovery_service.this : k => v.name }
}