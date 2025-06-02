output "aws_route53_record_root" {
  description = "Route53 record for the root domain"
  value       = aws_route53_record.root.fqdn
}

output "aws_route53_record_www" {
  description = "Route53 record for the www subdomain"
  value       = aws_route53_record.www.fqdn
}

output "aws_route53_record_app" {
  description = "Route53 record for the app subdomain"
  value       = aws_route53_record.app.fqdn
}

output "aws_route53_zone_id" {
  description = "The ID of the Route 53 hosted zone"
  value       = data.aws_route53_zone.main.zone_id
}

output "aws_route53_zone_name" {
  description = "The name of the Route 53 hosted zone"
  value       = data.aws_route53_zone.main.name
}

output "aws_route53_zone_fqdn" {
  description = "The fully qualified domain name of the Route 53 hosted zone"
  value       = data.aws_route53_zone.main.name_servers[0]
}

output "aws_route53_zone_name_servers" {
  description = "The name servers of the Route 53 hosted zone"
  value       = data.aws_route53_zone.main.name_servers
}

output "aws_route53_zone_comment" {
  description = "Comment for the Route 53 hosted zone"
  value       = data.aws_route53_zone.main.comment
}

output "aws_route53_zone_private_zone" {
  description = "Indicates if the Route 53 hosted zone is private"
  value       = data.aws_route53_zone.main.private_zone
}
