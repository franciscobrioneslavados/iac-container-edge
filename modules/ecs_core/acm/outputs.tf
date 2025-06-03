output "acm_certificate_arn" {
  description = "ARN of the ACM Certificate"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "acm_certificate_validation_id" {
  description = "ID of the ACM Certificate Validation"
  value       = aws_acm_certificate_validation.main.id
}

output "acm_certificate_domain_name" {
  description = "Domain name for the ACM Certificate"
  value       = aws_acm_certificate.main.domain_name
}
